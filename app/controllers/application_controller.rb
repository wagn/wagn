# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include LocationHelper
  include Recaptcha::Verify
  include ActionView::Helpers::SanitizeHelper

  helper :all
  before_filter :per_request_setup, :except=>[:fast_404]
  layout :wagn_layout, :except=>[:fast_404]

  attr_accessor :recaptcha_count

  def fast_404
    message = "<h1>404 Page Not Found</h1>"
    render :text=>message, :layout=>false, :status=>404
  end

  protected

  def per_request_setup
#    ActiveSupport::Notifications.instrument 'wagn.per_request_setup', :message=>"" do
      request.format = :html if !params[:format] #is this used??

      # these should not be Wagn::Conf, but more like WagnEnv
      Wagn::Conf[:host] = host = request.env['HTTP_HOST']
      Wagn::Conf[:base_url] = 'http://' + host
      Wagn::Conf[:main_name] = nil
      Wagn::Conf[:controller] = self

      Wagn::Renderer.ajax_call = ajax?
      Wagn::Renderer.current_slot = nil

      Wagn::Cache.renew

      #warn "set curent_user (app-cont) #{self.session_user}, U.cu:#{Session.user_id}"
      Session.user = self.session_user || Card::AnonID
      #warn "set curent_user a #{session_user}, U.cu:#{Session.user_id}"

      # RECAPTCHA HACKS
      Wagn::Conf[:recaptcha_on] = !Session.logged_in? &&     # this too
        !!( Wagn::Conf[:recaptcha_public_key] && Wagn::Conf[:recaptcha_private_key] )
      @recaptcha_count = 0

      @action = params[:action]
#    end
  end

  def wagn_layout
    layout = nil
    respond_to do |format|
      format.html { layout = 'application' unless ajax? }
    end
    layout
  end

  def ajax?
    request.xhr? || params[:simulate_xhr]
  end

  def html?
    [nil, 'html'].member?(params[:format])
  end

  # ------------------( permission filters ) -------
  def read_ok
    @card.ok?(:read) || deny(:read)
  end


  # ----------( rendering methods ) -------------

  def wagn_redirect url
    if ajax?
      render :text => url, :status => 303
    else
      redirect_to url
    end
  end

  def deny action=nil
    params[:action] = action if action
    @card.error_view = :denial
    @card.error_status = 403
    errors
  end

  def errors options={}
    @card ||= Card.new
    view   = options[:view]   || (@card && @card.error_view  ) || :errors
    status = options[:status] || (@card && @card.error_status) || 422
    show view, status
  end

  def show view = nil, status = 200
    ext = request.parameters[:format]
    known = FORMATS.split('|').member? ext

    if !known && @card && @card.error_view
      ext, known = 'txt', true
      # render simple text for errors on unknown formats; without this, file/image permissions checks are meaningless
    end

    case
    when known                # renderers can handle it
      renderer = Wagn::Renderer.new @card, :format=>ext, :controller=>self
      render :text=>renderer.render_show( :view => view || params[:view] ),
        :status=>(renderer.error_status || status)
    when show_file            # send_file can handle it
    else                      # dunno how to handle it
      render :text=>"unknown format: #{extension}", :status=>404
    end
  end

  def show_file
    return fast_404 if !@card

    @card.selected_rev_id = (@rev_id || @card.current_revision_id).to_i
    format = @card.attachment_format(params[:format])
    return fast_404 if !format

    if ![format, 'file'].member?( params[:format] )
      return redirect_to( request.fullpath.sub( /\.#{params[:format]}\b/, '.' + format ) ) #@card.attach.url(style) )
    end

    style = @card.attachment_style @card.type_id, ( params[:size] || @style )
    return fast_404 if style == :error

    # check file existence?  or just rescue MissingFile errors and raise NotFound?
    # we do see some errors from not having this, though I think they're mostly from legacy issues....

    send_file @card.attach.path( *[style].compact ), #nil or empty arg breaks 1.8.7
      :type => @card.attach_content_type,
      :filename =>  "#{@card.cardname.url_key}#{style.blank? ? '' : '-'}#{style}.#{format}",
      :x_sendfile => true,
      :disposition => (params[:format]=='file' ? 'attachment' : 'inline' )
  end


  rescue_from Exception do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"

    view, status = case exception
    when Wagn::NotFound, ActiveRecord::RecordNotFound
      [ :not_found, 404 ]
    when Wagn::PermissionDenied, Card::PermissionDenied
      [ :denial, 403]
    when Wagn::BadAddress, ActionController::UnknownController, AbstractController::ActionNotFound
      [ :bad_address, 404 ]
    else
      notify_airbrake exception if Airbrake.configuration.api_key

      if [Wagn::Oops, ActiveRecord::RecordInvalid].member?( exception.class ) && @card && @card.errors.any?
        [ :errors, 422]
      else
        Rails.logger.info "\n\nController exception: #{exception.message}"
        Rails.logger.debug exception.backtrace*"\n"
        Rails.logger.level == 0 ? raise( exception ) : [ :server_error, 500 ]
      end
    end

    errors :view=>view, :status=>status
  end

end


