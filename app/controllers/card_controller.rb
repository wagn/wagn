class CardController < ApplicationController
  helper :wagn

  EDIT_ACTIONS = [ :edit, :update, :rollback, :save_draft, :watch, :create_account, :update_account ]
  LOAD_ACTIONS =  EDIT_ACTIONS + [ :show_file, :show, :index, :comment, :remove, :view, :changes, :options, :related ]

  before_filter :index_preload, :only=> [ :index ]
  before_filter :show_file_preload, :only=> [ :show_file ]
  
  before_filter :load_card!, :only=>LOAD_ACTIONS
  before_filter :set_main

  before_filter :view_ok,   :only=> LOAD_ACTIONS
#  before_filter :create_ok, :only=>[ :new, :create ]
  before_filter :update_ok, :only=> EDIT_ACTIONS
  before_filter :remove_ok, :only=>[ :remove ]



  #----------( CREATE )
  
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


  #----------( READ )

  def show
    save_location if params[:format].nil? || params[:format].to_sym==:html
    render_show
  end


  def show_file
    render_show_file
  end

  def index()    show                  end
  def view()     render_show           end
  def changes()  render_show :changes  end
  def options()  render_show :options  end
  def related()  render_show :related  end
  def edit()     render_show :edit     end


  def new
    args = params[:card] || {}
    args[:type] ||= params[:type] # for /new/:type shortcut

    @card = Card.new args
    @title = "New Card"  #this doesn't work.
    
    if @card.ok? :create
      render_show :new
    else
      render_denied 'create'
    end
  end


  #--------------( UPDATE )


  def update
    @card = @card.refresh # (cached card attributes often frozen)
    args=params[:card] || {}
    args[:typecode] = Cardtype.classname_for(args.delete(:type)) if args[:type]
    
    @card.update_attributes(args)

    if !@card.errors[:confirmation_required].empty?
      @card.confirm_rename = @card.update_referencers = true
      params[:attribute] = 'name'
      render_show :edit
    elsif !@card.errors.empty?
      render_card_errors
    else
      render_success
    end
  end


  ## the following three methods need to be merged into #update

  def save_draft
    @card.save_draft( params[:card][:content] )
    render :text=>'success'
  end

  def comment
    raise(Wagn::NotFound,"Action comment should be post with card[:comment]") unless request.post? and params[:card]
    comment = params[:card][:comment];
    if User.current_user.login == 'anon'
      session[:comment_author] = author = params[:card][:comment_author]
      author = "#{author} (Not signed in)"
    else
      username=User.current_user.card.name
      author = "[[#{username}]]"
    end
    comment = comment.split(/\n/).map{|c| "<p>#{c.empty? ? '&nbsp;' : c}</p>"}.join("\n")
    @card.comment = "<hr>#{comment}<p><em>&nbsp;&nbsp;--#{author}.....#{Time.now}</em></p>"
    @card.save!
    render_show
  end

  def rollback
    revision = @card.revisions[params[:rev].to_i - 1]
    @card.update_attributes! :content=>revision.content
    @card.attachment_link revision.id
    render_show
  end



  #------------( DELETE )

  def remove
    @card.confirm_destroy = params[:confirm_destroy]
    @card.destroy
    
    return render_show(:remove) if !@card.errors[:confirmation_required].empty?  ## renders remove.erb, which is essentially a confirmation box.  

    discard_locations_for(@card) 

    render_success 'REDIRECT: TO-PREVIOUS'
  end


  #-------- ( ACCOUNT METHODS )
  
  def update_account
    @extension = @card.extension 
    
    if params[:save_roles]
      User.ok! :assign_user_roles
      role_hash = params[:user_roles] || {}
      @extension.roles = Role.find role_hash.keys
    end

    if @extension && params[:extension]
      @extension.update_attributes!(params[:extension])
    end
    
    flash[:notice] ||= "Got it!  Your changes have been saved."  #ENGLISH
    params[:attribute] = :account
    render_show :options
  end

  def create_account
    User.ok!(:create_accounts) && @card.ok?(:update)
    email_args = { :subject => "Your new #{Wagn::Conf[:site_title]} account.",   #ENGLISH
                   :message => "Welcome!  You now have an account on #{Wagn::Conf[:site_title]}." } #ENGLISH
    @user, @card = User.create_with_card(params[:user],@card, email_args)
    raise ActiveRecord::RecordInvalid.new(@user) if !@user.errors.empty?
    @extension = User.new(:email=>@user.email)
#    flash[:notice] ||= "Done.  A password has been sent to that email." #ENGLISH
    params[:attribute] = :account
    render_show :options
  end

  
  #-------- ( MISFIT METHODS )
  
  
  def watch
    watchers = Card.fetch_or_new( @card.cardname.star_rule(:watchers ) )
    watchers = watchers.refresh if watchers.frozen?
    watchers.send((params[:toggle]=='on' ? :add_item : :drop_item), User.current_user.card.name)
    ajax? ? render_show(:watch) : view
  end


  private
  
  #-------( FILTERS )
  
  def show_file_preload
    #warn "show preload #{params.inspect}"
    @original_id = params[:id]
    params[:id] = @original_id.sub(/(-(#{Card::STYLES*'|'}))?(-\d+)?(\.[^\.]*)?$/) do
      @style = $1.nil? ? 'original' : $2
      @rev_id = $3 && $3[1..-1]
      params[:format] = $4[1..-1] if $4
      ''
    end
  end
  
  
  def index_preload
    User.no_logins? ? 
      redirect_to( Card.path_setting '/admin/setup' ) : 
      params[:id] = (Card.setting('*home') || 'Home').to_cardname.to_url_key
  end
  
  def set_main
    Wagn::Conf[:main_name] = params[:main] || (@card && @card.name) || '' # will be wagn.main ?
  end
  
  
  # --------------( LOADING ) ----------
  def load_card!
    load_card
    case
    when !@card || @card.name.nil? || @card.name.empty?  #no card or no name -- bogus request, deserves error
      raise Wagn::NotFound, "We don't know what card you're looking for."
    when @card.known? # default case
      @card
    when params[:view] =~ /rule|missing/
      # FIXME this is a hack so that you can view load rules that don't exist.  need better approach 
      # (but this is not tested; please don't delete without adding a test) 
      @card
    when ajax? || ![nil, 'html'].member?(params[:format])  #missing card, nonstandard request
      ##  I think what SHOULD happen here is that we render the missing view and let the Renderer decide what happens.
      raise Wagn::NotFound, "We can't find a card named #{@card.name}"  
    when @card.ok?(:create)  # missing card, user can create
      params[:card]={:name=>@card.name, :type=>params[:type]}
      self.new
      false
    else
      render :action=>'missing' 
      false     
    end
  end

  def load_card
    return @card=nil unless id = params[:id]
    return (@card=Card.find(id); @card.include_set_modules; @card) if id =~ /^\d+$/
    name = Wagn::Cardname.unescape(id)
    card_params = params[:card] ? params[:card].clone : {}
    @card = Card.fetch_or_new(name, card_params)
  end


  #---------( RENDER HELPERS)
  
  def render_show(view = nil)
    extension = request.parameters[:format]
    #warn "render_show #{extension}"
    if FORMATS.split('|').member?( extension )

      render(:text=> begin
        respond_to() do |format|
          format.send(extension) do
            renderer = Wagn::Renderer.new(@card, :format=>extension, :controller=>self)
            renderer.render_show :view=>view
          end
        end
      end)
    elsif render_show_file
      return
    else
      return "unknown format: #{extension}"
    end
  end
  
  def render_show_file
    return render_fast_404 if !@card #will it ever get here
    @card.selected_rev_id = @rev_id || @card.current_revision_id
  
    format = @card.attachment_format(params[:format])
    return render_fast_404 if !format
    if format != :ok && params[:format] != 'file'
      return redirect_to( Wagn::Conf[:root_path] + "/files/" + @original_id.sub(params[:format], format) ) 
    end
    
    style = @card.attachment_style( @card.typecode, params[:size] || @style)
    render_fast_404 if !style
  
    send_file @card.attach.path(style), 
      :type => @card.attach_content_type,
      :filename =>  "#{@card.cardname.to_url_key}-#{style}.#{format}",
      :x_sendfile => true,
      :disposition => (params[:format]=='file' ? 'attachment' : 'inline' )
  end
  
  def render_success(default_target='TO-CARD')
    target = params[:success] || default_target
    redirect = !ajax?

    if target =~ /^REDIRECT:\s*(.+)/
      redirect, target = true, $1
    end
    
    target = case target
      when 'TO-PREVIOUS'   ;  previous_location
      when 'TO-CARD'       ;  @card
      when /^(http|\/)/    ;  target
      when /^TEXT:\s*(.+)/ ;  $1
      else                 ;  Card.fetch_or_new(target)
      end
    
    case
    when  redirect        ; wagn_redirect ( Card===target ? card_path(target) : target )
    when  String===target ; render :text => target 
    else  @card = target  ; render_show
    end
  end

end

