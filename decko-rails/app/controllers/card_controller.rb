# -*- encoding : utf-8 -*-

require_dependency 'card'

Decko.card_paths_and_config Card.paths

require_dependency 'card/content'
#require_dependency 'card/machine'
#require_dependency 'card/machine_input'
#require_dependency 'card/machine_output'
require_dependency 'card/action'
require_dependency 'card/act'
require_dependency 'card/change'
require_dependency 'card/chunk'
require_dependency 'card/reference'
require_dependency 'card/mailer'
require_dependency 'decko/location'
require_dependency 'decko/exceptions'

Card::Loader.load_mods if Card.count > 0

class CardController < ActionController::Base

  include Card::Location
  include Decko::Location
  include Recaptcha::Verify

  before_filter :per_request_setup, :except => [:asset]
  before_filter :load_id, :only => [ :read ]
  before_filter :load_card, :except => [:asset]
  before_filter :refresh_card, :only=> [ :create, :update, :delete, :rollback ]
  
  if Wagn.config.request_logger
    require 'csv'
    after_filter :request_logger 
  end
  
  layout nil

  attr_reader :card
  
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
  #  CORE METHODS
  
  def create
    handle { card.save }
  end

  def read
    save_location # should be an event!
    show
  end

  def update
    card.new_card? ? create : handle { card.update_attributes params[:card] }
  end

  def delete
    discard_locations_for card #should be an event
    params[:success] ||= 'REDIRECT: *previous'
    handle { card.delete }
  end
  
  def asset
    Rails.logger.info "Routing assets through Card. Recommend symlink from Deck to Card gem using 'rake wagn:update_assets_symlink'"
    send_file_inside Wagn.paths['gem-assets'].existent.first, [ params[:filename], params[:format] ].join('.'), :x_sendfile => true
  end
  
  private
  
  # make sure that filename doesn't leave allowed_path using ".."
  def send_file_inside(allowed_path, filename, options = {})
    if filename.include? "../"
      raise Decko::BadAddress
    else
      send_file File.join(allowed_path, filename), options
    end
  end
  
  #-------( FILTERS )

  def per_request_setup
    request.format = :html if !params[:format] #is this used??
    Card::Cache.renew
    Card::Env.reset :controller=>self
    Card::Auth.set_current_from_session
  end


  def load_id
    params[:id] ||= case
      when Card::Auth.needs_setup?
        params[:card] = { :type_id => Card.default_accounted_type_id }
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
    raise Decko::BadAddress
  end
  

  def load_card
    @card = case params[:id]
      when '*previous'
        return card_redirect( previous_location )
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
          Card.fetch mark, :new=>opts
        end
      end
    raise Card::NotFound unless @card
    
    if action = @card.find_action_by_params( params )
      @card.selected_action_id = action.id
    end
    
    Card::Env[:main_name] = params[:main] || (card && card.name) || ''
    render_errors if card.errors.any?
    true
  end

  def refresh_card
    @card =  card.refresh
  end

  def request_logger
    unless env["REQUEST_URI"] =~ %r{^/files?/}
      log = []
      log << (Card::Env.ajax? ? "YES" : "NO")
      log << env["REMOTE_ADDR"]
      log << Card::Auth.current_id
      log << card.name
      log << action_name
      log << params['view'] || (s = params['success'] and  s['view'])
      log << env["REQUEST_METHOD"]
      log << status
      log << env["REQUEST_URI"]
      log << DateTime.now.to_s
      log << env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/^[a-z]{2}/).first
      log << env["HTTP_REFERER"]
      
      log_dir = (Card.paths['request_log'] || Card.paths['log']).first
      log_filename = "#{Date.today}_#{Rails.env}.csv"
      File.open(File.join(log_dir,log_filename), "a") do |f|
        f.write CSV.generate_line(log)
      end
    end
  end
  
  protected

  def ajax?
    Card::Env.ajax?
  end

  def html?
    [nil, 'html'].member?(params[:format])
  end

  # ----------( rendering methods ) -------------

  def card_redirect url
    url = card_url url #make sure we have absolute url
    if ajax?
      # lets client reset window location (not just receive redirected response)
      # formerly used 303 response, but that gave IE the fits
      render :json => {:redirect=> url}
    else
      redirect_to url
    end
  end

  def handle
    yield ? success : render_errors
  end


  def success
    redirect, new_params = !ajax?, {}

    target = case params[:success]
      when Hash
        new_params = params[:success]
        redirect ||= !!(new_params.delete :redirect)
        new_params.delete :id
      when /^REDIRECT:\s*(.+)/
        redirect=true
        $1
      when nil  ;  '_self'
      else      ;   params[:success]
      end

    target = case target
      when '*previous'     ;  previous_location #could do as *previous
      when /^(http|\/)/    ;  target
      when /^TEXT:\s*(.+)/ ;  $1
      when ''              ;  ''
      else                 ;  Card.fetch target.to_name.to_absolute(card.cardname), :new=>{}
      end

    case
    when redirect
      target = page_path target.cardname, new_params if Card === target
      card_redirect target
    when String===target
      render :text => target
    else
      @card = target
      self.params = self.params.merge new_params #need tests.  insure we get slot, main...
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
        
    format = request.parameters[:format]
    format = :file if params[:explicit_file] or !Card::Format.registered.member? format #unknown format

    opts = ( params[:slot] || {} ).deep_symbolize_keys
    view ||= params[:view]      

    formatter = card.format( :format=>format )
    result = formatter.show view, opts
    status = formatter.error_status || status
  
    if format==:file && status==200
      send_file *result
    elsif status == 302
      card_redirect result
    else
      args = { :text=>result, :status=>status }
      args[:content_type] = 'text/text' if format == :file
      render args
    end
#    end
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
      when Decko::BadAddress
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

