# -*- encoding : utf-8 -*-

require_dependency "card"

require_dependency "wagn/exceptions"
require_dependency "card/mailer"  # otherwise Net::SMTPError rescues can cause
# problems when error raised comes before Card::Mailer is mentioned

class CardController < ActionController::Base
  include Card::Location
  include Recaptcha::Verify

  layout nil
  attr_reader :card

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  PUBLIC METHODS

  def create
    handle { card.save }
  end

  def read
    show
  end

  def update
    card.new_card? ? create : handle { card.update_attributes params[:card] }
  end

  def delete
    handle { card.delete }
  end

  # DEPRECATED
  def asset
    Rails.logger.info "Routing assets through Card. Recommend symlink from " \
                      'Deck to Card gem using "rake wagn:update_assets_symlink"'
    asset_path = Decko::Engine.paths["gem-assets"].existent.first
    filename   = [params[:filename], params[:format]].join(".")
    send_asset asset_path, filename, x_sendfile: true
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  PRIVATE METHODS

  private

  #-------( FILTERS )

  before_filter :setup, except: [:asset]
  before_filter :authenticate, except: [:asset]
  before_filter :load_id, only: [:read]
  before_filter :load_card, except: [:asset]
  before_filter :refresh_card, only: [:create, :update, :delete, :rollback]

  def setup
    request.format = :html unless params[:format] # is this used??
    Card::Loader.refresh_script_and_style if Rails.env.development?
    Card::Cache.renew
    Card::Env.reset controller: self
  end

  def authenticate
    if params[:token]
      ok = Card::Auth.set_current_from_token params[:token], params[:current]
      raise Card::Oops, "token authentication failed" unless ok
      # arguably should be PermissionDenied; that requires a card object,
      # and that's not loaded yet.
    else
      Card::Auth.set_current_from_session
    end
  end

  def load_id
    params[:id] =
      case params[:id]
      when "*previous" then return card_redirect(Card::Env.previous_location)
      when nil         then determine_id
      else                  validate_id_encoding params[:id]
      end
  end

  def load_card
    @card = new_or_fetch_card
    raise Card::NotFound unless @card

    @card.select_action_by_params params #
    Card::Env[:main_name] = params[:main] || (card && card.name) || ""

    card.errors.any? ? render_errors : true
  end

  def refresh_card
    @card = card.refresh
  end

  # ----------( HELPER METHODS ) -------------

  def new_or_fetch_card
    opts = card_opts
    if params[:action] == "create"
      # FIXME: we currently need a "new" card to catch duplicates
      # (otherwise save will just act like a normal update)
      # We may need a "#create" instance method to handle this checking?
      Card.new opts
    else
      mark = params[:id] || opts[:name]
      Card.fetch mark, new: opts
    end
  end

  def card_opts
    opts = (params[:card] || {}).clone
    # clone so that original params remain unaltered.  need deeper clone?
    opts[:type] ||= params[:type] if params[:type]
    # for /new/:type shortcut.  we should fix and deprecate this.
    opts[:name] ||= params[:id].to_s.tr("_", " ")
    # move handling to Card::Name?
    opts
  end

  def determine_id
    case
    when needs_setup?
      prepare_setup_card!
    when params[:card] && params[:card][:name]
      params[:card][:name]
    when Card::Format.tagged(params[:view], :unknown_ok)
      ""
    else
      Card.global_setting(:home) || "Home"
    end
  end

  def needs_setup?
    Card::Auth.needs_setup? && Card::Env.html?
  end

  def prepare_setup_card!
    params[:card] = { type_id: Card.default_accounted_type_id }
    params[:view] = "setup"
    ""
  end

  def validate_id_encoding id
    # we should find the place where we produce these bad urls
    id.valid_encoding? ? id : id.force_encoding("ISO-8859-1").encode("UTF-8")
  end

  def send_asset path, filename, options={}
    if filename.include? "../"
      # for security, block relative paths
      raise Wagn::BadAddress
    else
      send_file File.join(path, filename), options
    end
  end

  def card_redirect url
    url = card_url url # make sure we have absolute url
    if ajax?
      # lets client reset window location (not just receive redirected response)
      # formerly used 303 response, but that gave IE the fits
      render json: { redirect: url }
    else
      redirect_to url
    end
  end

  def handle
    card.act(success: true) do
      yield ? render_success : render_errors
    end
  end

  def render_success
    success.name_context = @card.cardname
    return card_redirect success.to_url if !ajax? || success.hard_redirect?
    return render text: success.target if success.target.is_a? String

    @card = success.target
    update_params_for_success
    @card.select_action_by_params params
    show
  end

  def render_errors
    # FIXME: should prioritize certain error classes
    code = nil
    card.errors.each do |key, _msg|
      break if (code = Card.error_codes[key])
    end
    view, status = code || [:errors, 422]
    show view, status
  end

  def show view=nil, status=200
    card.action = :read
    card.content = card.last_draft_content if use_draft?

    view ||= params[:view]
    slot_opts = (params[:slot] || {}).deep_symbolize_keys

    format = format_from_params
    formatter = card.format(format.to_sym)
    result = card.act { formatter.page view, slot_opts }
    status = formatter.error_status || status

    deliver format, result, status
  end

  def deliver format, result, status
    if format == :file && status == 200
      send_file(*result)
    elsif status == 302
      card_redirect result
    else
      args = { text: result, status: status }
      args[:content_type] = "text/text" if format == :file
      render args
    end
  end

  rescue_from StandardError do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"

    @card ||= Card.new
    Card::Error.current = exception
    view =

      case exception
      ## arguably the view and status should be defined in the error class;
      ## some are redundantly defined in view
      when Card::Oops, Card::BadQuery
        card.errors.add :exception, exception.message
        # these error messages are visible to end users and are generally not
        # treated as bugs.
        # Probably want to rename accordingly.
        :errors
      when Card::PermissionDenied
        :denial
      when Card::NotFound, ActiveRecord::RecordNotFound,
           ActionController::MissingFile
        :not_found
      when Wagn::BadAddress
        :bad_address
      else
        # the following indicate a code problem and therefore require full
        # logging
        @card.notable_exception_raised

        if ActiveRecord::RecordInvalid === exception
          :errors
        # could also just check non-production mode...
        elsif Rails.logger.level == 0
          raise exception
        else
          :server_error
        end
      end

    show view
  end

  def ajax?
    Card::Env.ajax?
  end

  def success
    Card::Env[:success]
  end

  def format_from_params
    return :file if params[:explicit_file]
    format = request.parameters[:format]
    return :file unless Card::Format.registered.member?(format) # unknown format
    format
  end

  def update_params_for_success
    if success.soft_redirect?
      self.params = success.params
    else
      # need tests. insure we get slot, main...
      params.merge! success.params
    end
  end

  def use_draft?
    params[:edit_draft] && card.drafts.present?
  end
end
