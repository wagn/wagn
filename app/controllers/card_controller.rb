# -*- encoding : utf-8 -*-

require_dependency 'card'

class CardController < ActionController::Base

  include Wagn::Location
  include Recaptcha::Verify

  before_filter :per_request_setup
  before_filter :load_id, :only => [ :read ]
  before_filter :load_card
  before_filter :refresh_card, :only=> [ :create, :update, :delete, :rollback ]

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

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## the following methods need to be merged into #update

  def save_draft
    if card.save_draft params[:card][:content]
      render :nothing=>true
    else
      render_errors
    end
  end

  def rollback
    revision = card.revisions[params[:rev].to_i - 1]
    card.update_attributes! :content=>revision.content
    card.attachment_link revision.id
    show
  end

  def watch
    watchers = card.fetch :trait=>:watchers, :new=>{}
    watchers = watchers.refresh
    myname = Card::Auth.current.name
    watchers.send((params[:toggle]=='on' ? :add_item : :drop_item), myname)
    watchers.save!
    ajax? ? show(:watch) : read
    
  end




  private
  
  
  #-------( FILTERS )

  def per_request_setup
    request.format = :html if !params[:format] #is this used??
    Wagn::Cache.renew
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
    raise Wagn::BadAddress
  end
  

  def load_card
    @card = case params[:id]
      when '*previous'
        return wagn_redirect( previous_location )
      when /^\~(\d+)$/
        Card.fetch( $1.to_i ) or raise Wagn::NotFound 
      when /^\:(\w+)$/
        Card.fetch $1.to_sym
      else
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
    @card.selected_revision_id = params[:rev].to_i if params[:rev]

    Card::Env[:main_name] = params[:main] || (card && card.name) || ''
    render_errors if card.errors.any?
    true
  end

  def refresh_card
    @card =  card.refresh
  end


  protected

  def ajax?
    Card::Env.ajax?
  end

  def html?
    [nil, 'html'].member?(params[:format])
  end

  # ----------( rendering methods ) -------------

  def wagn_redirect url
    url = wagn_url url #make sure we have absolute url
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
      wagn_redirect target
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
      wagn_redirect result
    else
      args = { :text=>result, :status=>status }
      args[:content_type] = 'text/text' if format == :file
      render args
    end
  end


  rescue_from Exception do |exception|
    Rails.logger.info "exception = #{exception.class}: #{exception.message}"

    @card ||= Card.new

    view = case exception
      ## arguably the view and status should be defined in the error class;
      ## some are redundantly defined in view
      when Card::Oops, Card::Query
        card.errors.add :exception, exception.message 
        # Card::Oops error messages are visible to end users and are generally not treated as bugs.
        # Probably want to rename accordingly.
        :errors
      when Card::PermissionDenied, Wagn::PermissionDenied
        :denial
      when Wagn::NotFound, ActiveRecord::RecordNotFound, ActionController::MissingFile
        :not_found
      when Wagn::BadAddress
        :bad_address
      else #the following indicate a code problem and therefore require full logging
        Rails.logger.info exception.backtrace*"\n"
        notify_airbrake exception if Airbrake.configuration.api_key

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

