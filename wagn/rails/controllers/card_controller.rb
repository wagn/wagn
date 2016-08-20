# -*- encoding : utf-8 -*-

require_dependency "card"

require_dependency "wagn/exceptions"
require_dependency "wagn/response"
require_dependency "card/mailer"  # otherwise Net::SMTPError rescues can cause
# problems when error raised comes before Card::Mailer is mentioned

# Wagn's only controller.
class CardController < ActionController::Base
  include Card::Env::Location
  include Recaptcha::Verify
  include Wagn::Response

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

  # @deprecated
  def asset
    Rails.logger.info "Routing assets through Card. Recommend symlink from " \
                      'Deck to Card gem using "rake wagn:update_assets_symlink"'
    send_deprecated_asset
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
    Card::Mod::Loader.refresh_script_and_style if Rails.env.development?
    Card::Cache.renew
    Card::Env.reset controller: self
  end

  def authenticate
    Card::Auth.set_current params[:token], params[:current]
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
    @card = Card.deep_fetch params
    raise Card::Error::NotFound unless @card
    @card.select_action_by_params params #
    Card::Env[:main_name] = params[:main] || (card && card.name) || ""
    card.errors.any? ? render_errors : true
  end

  def refresh_card
    @card = card.refresh
  end

  # ----------( HELPER METHODS ) -------------

  def handle
    card.act(success: true) do
      yield ? render_success : render_errors
    end
  end

  def render_success
    success = Card::Env.success
    if !Card::Env.ajax? || success.hard_redirect?
      card_redirect success.to_url
    elsif success.target.is_a? String
      render text: success.target
    else
      reset_card success.target
      show
    end
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

  def render_errors
    view, status = Card::Error.view_and_status(card) || [:errors, 422]
    show view, status
  end

  def determine_id
    case
    when prompt_setup?
      prepare_setup_card!
    when params[:card] && params[:card][:name]
      params[:card][:name]
    when Card::Format.tagged(params[:view], :unknown_ok)
      ""
    else
      Card.global_setting(:home) || "Home"
    end
  end

  def prompt_setup?
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





  def format_from_params
    return :file if params[:explicit_file]
    format = request.parameters[:format]
    return :file unless Card::Format.registered.member?(format) # unknown format
    format
  end

  def use_draft?
    params[:edit_draft] && card.drafts.present?
  end

  rescue_from StandardError do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"
    @card ||= Card.new
    Card::Error.current = exception
    show Card::Error.exception_view(@card, exception)
  end
end
