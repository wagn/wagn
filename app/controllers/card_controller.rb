class CardController < ApplicationController
  helper :wagn, :card

  EDIT_ACTIONS = [ :edit, :update, :rollback, :save_draft, :watch, :unwatch, :create_account, :update_account ]
  LOAD_ACTIONS =  EDIT_ACTIONS + [ :show, :index, :mine, :comment, :remove, :view, :changes, :options, :related ]

  before_filter :index_preload, :only=> [ :index ]
  before_filter :mine_preload,  :only=> [ :mine ]
  
  before_filter :load_card!, :only=>LOAD_ACTIONS

  before_filter :view_ok,   :only=> LOAD_ACTIONS
#  before_filter :create_ok, :only=>[ :new, :create ]
  before_filter :update_ok,   :only=> EDIT_ACTIONS
  before_filter :remove_ok, :only=>[ :remove ]

#  before_filter :require_captcha, :only => [ :create, :update, :comment ]

  #----------( Special cards )

  def index_preload
    User.no_logins? ? 
      redirect_to( System.path_setting '/admin/setup' ) : 
      params[:id] = (System.setting('*home') || 'Home').to_cardname.to_url_key
  end

  def index() show  end

  def show
    save_location if params[:format].nil? || params[:format].to_sym==:html
    render_show
  end

  def new
    args = params[:card] || {}
    @type = ( args[:type] ||= params[:type] ) # for /new/:type shortcut

    @card = Card.new args
    if @card.ok? :create
      render( ajax? ?
        {:partial=>'views/new', :locals=>{ :card=>@card }} : #ajax
        {:action=> 'new'} ) #normal
    else
      render_denied('create')
    end
  end

  def create
    @card = Card.new params[:card]
    if @card.save
      render_success
    else
      render_card_errors      
    end
  end

  def create_or_update
    if @card = Card[ params[:card][:name] ]
      update
    else
      create
    end
  end


  #--------------( editing )

  def edit
    @attribute = params[:attribute] || 'content'
    render_show :edit
  end

  def update
    @card = @card.refresh # (cached card attributes often frozen)
    args=params[:card] || {}
    args[:typecode] = Cardtype.classname_for(args.delete(:type)) if args[:type]
    
#    # ~~~ REFACTOR! -- this conflict management handling is sloppy
#    #Rails.logger.debug "update set current_revision #{@card.name}, #{@card.current_revision}"
#    @current_revision_id = @card.current_revision.id
#    old_revision_id = card_args.delete(:current_revision_id) || @current_revision_id
#    if old_revision_id.to_i != @current_revision_id.to_i
#      changes  # FIXME -- this should probably be abstracted?
#      @no_changes_header = true
#      @changes = render_to_string :action=>'changes'
#      return render( :action=>:edit_conflict )
#    end
    # ~~~~~~  /REFACTOR ~~~~~ #

    @card.update_attributes(args)

    if !@card.errors[:confirmation_required].empty?
      @confirm = @card.confirm_rename = @card.update_referencers = true
      @attribute = 'name'
      render :action=>'edit'
    elsif !@card.errors.empty?
      render_card_errors
    else
      render_success
    end
  end

  def save_draft
    @card.save_draft( params[:card][:content] )
    render :text=>'success'
  end

  def comment
    raise(Wagn::NotFound,"Action comment should be post with card[:comment]") unless request.post? and params[:card]
    @comment = params[:card][:comment];
    if User.current_user.login == 'anon'
      @author = params[:card][:comment_author]
      session[:comment_author] = @author
      @author = "#{@author} (Not signed in)"
    else
      username=User.current_user.card.name
      #@author = "{{#{username}+image|size:icon}} [[#{username}]]"
      @author = "[[#{username}]]"
    end
    @comment=@comment.split(/\n/).map{|c| "<p>#{c.empty? ? '&nbsp;' : c}</p>"}.join("\n")
    @card.comment = "<hr>#{@comment}<p><em>&nbsp;&nbsp;--#{@author}.....#{Time.now}</em></p>"
    @card.save!
    render_show
  end

  def rollback
    load_card_and_revision
    @card.update_attributes! :content=>@revision.content
    render_show
  end

  #------------( deleting )

  def remove
#    return unless !captcha_required? || verify_captcha
    
    @card.confirm_destroy = params[:confirm_destroy]
    @card.destroy
    
    return if !@card.errors[:confirmation_required].empty?  ## renders remove.erb, which is essentially a confirmation box.  

    discard_locations_for(@card)
    
    url = params[:redirect] || params[:success]
    url = previous_location if [nil, 'TO_PREVIOUS_CARD'].member? url

    case 
    when !ajax?            ; wagn_redirect url
    when params[:redirect] ; wagn_redirect url
    when params[:success]  ; @card = Card.fetch_or_new(url); render_show 
    else                   ; render :text => "#{@card.name} removed"
    end
    render_show :remove
  end

  #---------------( tabs )

  def view
    render_show
  end

  def options
    @attribute = params[:attribute]
    @attribute ||= (@card.extension_type=='User' ? 'account' : 'settings')
    render_show :options
  end

  def changes
    load_card_and_revision
    @show_diff = (params[:mode] != 'false')
    @previous_revision = @card.previous_revision(@revision)
    render_show :changes
  end

  def related
    sources = [@card.typename,nil]
    sources.unshift '*account' if @card.extension_type=='User'
    @items = sources.map do |root|
      c = Card.fetch(root ? root.to_cardname.star_rule(:related) : '*related')
      c && c.item_names
    end.flatten.compact
#    @items << 'config'
    @current = params[:attribute] || @items.first.to_cardname.to_key
    render_show :related
  end


  #-------- ( ACCOUNT METHODS )
  
  def update_account
    @extension = @card.extension 
    
    if params[:save_roles]
      System.ok! :assign_user_roles
      role_hash = params[:user_roles] || {}
      @extension.roles = Role.find role_hash.keys
    end

    if @extension && params[:extension]
      @extension.update_attributes!(params[:extension])
    end
    
    flash[:notice] ||= "Got it!  Your changes have been saved."  #ENGLISH
    @attribute = :account
    render_show :options
  end

  def create_account
    System.ok!(:create_accounts) && @card.ok?(:update)
    email_args = { :subject => "Your new #{System.site_title} account.",   #ENGLISH
                   :message => "Welcome!  You now have an account on #{System.site_title}." } #ENGLISH
    @user, @card = User.create_with_card(params[:user],@card, email_args)
    raise ActiveRecord::RecordInvalid.new(@user) if !@user.errors.empty?
    @extension = User.new(:email=>@user.email)
#    flash[:notice] ||= "Done.  A password has been sent to that email." #ENGLISH
    @attribute = :account
    render_show :options
  end

  
  #-------- ( MISFIT METHODS )
  def watch
    watchers = Card.fetch_or_new( @card.cardname.star_rule(:watchers ) )
    watchers = watchers.refresh if watchers.frozen?
    watchers.add_item User.current_user.card.name
    #flash[:notice] = "You are now watching #{@card.name}"
    ajax? ? render(:inline=>%{<%= get_slot.watch_link %>}) : view
  end

  def unwatch
    watchers = Card.fetch_or_new( @card.cardname.star_rule(:watchers ) )
    watchers = watchers.refresh if watchers.frozen?
    watchers.drop_item User.current_user.card.name
    #flash[:notice] = "You are no longer watching #{@card.name}"
    ajax? ? render(:inline=>%{<%= get_slot.watch_link %>}) : view
  end

  protected
  
  
  def render_show(render_view = nil)
    render :text=>render_show_text(render_view)
  end
  
  def render_show_text(render_view)
    extension = request.parameters[:format]
    return "unknown format: #{extension}" if !FORMATS.split('|').member?( extension )
    
    respond_to do |format|
      format.send extension do
        Wagn::Renderer.new(@card, :format=>extension, :controller=>self).render(:show, :view=>render_view)
      end
    end
  end
  
  def render_success
    url = params[:redirect] || params[:success]
    
    if url == 'TO_CARD' or ( !ajax? && url.nil? )
      url = if @card.ok?(:read)
        card_path @card
      else
        '/'
      end
    end 
    
    if params[:redirect] || !ajax?
      wagn_redirect url
    else
      @card = Card.fetch_or_new(url) if url
      render_show
    end
  end
  

end

