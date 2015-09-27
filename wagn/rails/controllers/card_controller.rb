# -*- encoding : utf-8 -*-

require_dependency 'card'

require_dependency 'wagn/exceptions'
require_dependency 'card/mailer'  #otherwise Net::SMTPError rescues can cause problems when error raised comes before Card::Mailer is mentioned

class CardController < ActionController::Base

  include Card::Location
  include Recaptcha::Verify

  before_filter :per_request_setup, except: [:asset]
  before_filter :load_id, only: [ :read ]
  before_filter :load_card, except: [:asset]
  before_filter :refresh_card, only: [ :create, :update, :delete, :rollback ]

  layout nil

  attr_reader :card


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  CORE METHODS

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

  def asset
    Rails.logger.info "Routing assets through Card. Recommend symlink from Deck to Card gem using 'rake wagn:update_assets_symlink'"
    asset_path = Decko::Engine.paths['gem-assets'].existent.first
    filename   = [ params[:filename], params[:format] ].join('.')
    send_file_inside asset_path, filename , x_sendfile: true
  end


  private

  # make sure that filename doesn't leave allowed_path using ".."
  def send_file_inside(allowed_path, filename, options = {})
    if filename.include? "../"
      raise Wagn::BadAddress
    else
      send_file File.join(allowed_path, filename), options
    end
  end

  #-------( FILTERS )

  def per_request_setup
    request.format = :html if !params[:format] #is this used??
    Card::Cache.renew
    Card::Env.reset controller: self
    Card::Auth.set_current_from_session

    if params[:id] && !params[:id].valid_encoding?  # slightly better way to handle encoding issues (than the rescue in load_id)
                                                    # we should find the place where we produce these bad urls
      params[:id] = params[:id].force_encoding('ISO-8859-1').encode('UTF-8')
    end
  end


  def load_id
    params[:id] ||= case
      when Card::Auth.needs_setup?
        params[:card] = { type_id: Card.default_accounted_type_id }
        params[:view] = 'setup'
        ''
      when params[:card] && params[:card][:name]
        params[:card][:name]
      when Card::Format.tagged( params[:view], :unknown_ok )
        ''
      else
        Card.setting(:home) || 'Home'
      end
  rescue ArgumentError # less than perfect way to handle encoding issues.
    raise Wagn::BadAddress
  end


  def load_card
    @card = case params[:id]
      when '*previous'
        return card_redirect( Card::Env.previous_location )
      else  # get by name
        opts = params[:card] ? params[:card].clone : {}   # clone so that original params remain unaltered.  need deeper clone?
        opts[:type] ||= params[:type] if params[:type]    # for /new/:type shortcut.  we should fix and deprecate this.
        opts[:name] ||= params[:id].to_s.gsub( '_', ' ')  # move handling to Card::Name?

        if params[:action] == 'create'
          # FIXME we currently need a "new" card to catch duplicates (otherwise #save will just act like a normal update)
          # I think we may need to create a "#create" instance method that handles this checking.
          # that would let us get rid of this...
          Card.new opts
        else
          mark = params[:id] || opts[:name]
          Card.fetch mark, new: opts
        end
      end
    raise Card::NotFound unless @card

    @card.select_action_by_params params
    Card::Env[:main_name] = params[:main] || (card && card.name) || ''

    render_errors if card.errors.any?
    true
  end

  def refresh_card
    @card = card.refresh
  end


  protected

  def ajax?
    Card::Env.ajax?
  end

  def success
    Card::Env[:success]
  end

  # ----------( rendering methods ) -------------

  def card_redirect url
    url = card_url url #make sure we have absolute url
    if ajax?
      # lets client reset window location (not just receive redirected response)
      # formerly used 303 response, but that gave IE the fits
      render json: {redirect: url}
    else
      redirect_to url
    end
  end

  def handle
    card.run_callbacks :handle do
      yield ? render_success : render_errors
    end
  end

  def render_success
    success.name_context = @card.cardname
    if !ajax? || success.hard_redirect?
      card_redirect success.to_url
    elsif String === success.target
      render text: success.target
    else
      if success.soft_redirect?
        self.params = success.params
      else
        self.params.merge! success.params # #need tests. insure we get slot, main...
      end
      @card = success.target
      @card.select_action_by_params params
      show
    end
  end


  def render_errors
    #fixme - should prioritize certain error classes
    code = nil
    card.errors.each do |key, msg|
      break if code = Card.error_codes[ key ]
    end
    view, status = code || [ :errors, 422]
    show view, status
  end

  def show view = nil, status = 200
#    ActiveSupport::Notifications.instrument('card', message: 'CardController#show') do
    card.action = :read
    format = request.parameters[:format]
    format = :file if params[:explicit_file] or !Card::Format.registered.member? format #unknown format

    opts = ( params[:slot] || {} ).deep_symbolize_keys
    view ||= params[:view]

    if params[:edit_draft] && card.drafts.present?
      card.content = card.drafts.last.card_changes.last.value
    end
    formatter = card.format(format.to_sym)
    result = card.run_callbacks :show do
      formatter.show view, opts
    end
    status = formatter.error_status || status

    deliver format, result, status
  end


  def deliver format, result, status
    if format==:file && status==200
      send_file *result
    elsif status == 302
      card_redirect result
    else
      args = { text: result, status: status }
      args[:content_type] = 'text/text' if format == :file
      render args
    end
  end

  rescue_from StandardError do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"

    @card ||= Card.new
    Card::Error.current = exception


    view = case exception
      ## arguably the view and status should be defined in the error class;
      ## some are redundantly defined in view
      when Card::Oops, Card::Query
        card.errors.add :exception, exception.message
        # these error messages are visible to end users and are generally not treated as bugs.
        # Probably want to rename accordingly.
        :errors
      when Card::PermissionDenied
        :denial
      when Card::NotFound, ActiveRecord::RecordNotFound, ActionController::MissingFile
        :not_found
      when Wagn::BadAddress
        :bad_address
      else #the following indicate a code problem and therefore require full logging
        @card.notable_exception_raised

        if ActiveRecord::RecordInvalid === exception
          :errors
        elsif Rails.logger.level == 0 # could also just check non-production mode...
          raise exception
        else
          :server_error
        end
      end

    show view
  end



end



