class CardController < ApplicationController
  helper :wagn, :card

  EDIT_ACTIONS =  [ :edit, :update, :rollback, :save_draft, :watch, :unwatch ]
  LOAD_ACTIONS = EDIT_ACTIONS + [ :changes, :comment, :denied, :options, :quick_update, :update_codename, :related, :remove ]

  before_filter :load_card!, :only=>LOAD_ACTIONS
  before_filter :load_card_with_cache, :only => [:line, :view, :open ]

  before_filter :view_ok,   :only=> LOAD_ACTIONS
#  before_filter :create_ok, :only=>[ :new, :create ]
  before_filter :update_ok,   :only=> EDIT_ACTIONS
  before_filter :remove_ok, :only=>[ :remove ]

  before_filter :require_captcha, :only => [ :create, :update, :comment, :quick_update ]

  #----------( Special cards )

  def index
    if User.no_logins?
      redirect_to '/admin/setup'
    else
      params['id'] = (System.setting('*home') || 'Home').to_url_key
      show
    end
  end

  def mine
    redirect_to :controller=>'card',:action=>'show', :id=>Wagn::Cardname.escape(User.current_user.card.name)
  end

  #---------( VIEWING CARDS )

  def show
    params[:_keyword] && params[:_keyword].gsub!('_',' ') ## this will be unnecessary soon.

    @card_name = Wagn::Cardname.unescape(params['id'] || '')
    @card_name = System.site_title if (@card_name.nil? or @card_name.empty?)
    @card =   Card.fetch_or_new(@card_name)    
      
    if params[:format].nil? || params[:format].to_sym==:html
      if @card.new_record? && !@card.virtual?  # why doesnt !known? work here?
        params[:card]={:name=>@card_name, :type=>params[:type]}
        return case
          when @card.ok?(:create) ;  self.new
          when logged_in?         ;  render :action=>'denied'
          else                    ;  render :action=>'missing' 
          end
      else
        save_location
      end
    end
    
    return if !view_ok # if view is not ok, it will render denied. return so we dont' render twice
    render_show
  end

  def render_show
    render(:text=>render_show_text)
  end
  
  def render_show_text
    request.format = :html if !params[:format]
    
    known_formats = FORMATS.split('|')
    f_ext = request.parameters[:format]
    return "unknown format: #{f_ext}" if !known_formats.member?( f_ext )
    
    respond_to do |format|
      known_formats.each do |f|
        format.send f do
          return Wagn::Renderer.new(@card, 
            :format=>f, :flash=>flash, :params=>params, :controller=>self
          ).render(:show)
        end
      end
    end
  end
  

  #----------------( MODIFYING CARDS )

  #----------------( creating)
  def new
    @args = (params[:card] ||= {})
    @args[:name] ||= params[:id] # for ajax (?)
    @args[:type] ||= params[:type] # for /new/:type shortcut
    [:name, :type, :content].each {|key| @args.delete(key) unless a=@args[key] and !a.blank?} #filter blank args
    @args.delete(:attachment_id) # was breaking changes to and away from image / file.  should refactor so this is unnecessary.

    if @args[:name] and Card.exists?(@args[:name]) #card exists
      render :text => "<span>Oops, <strong>#{@args[:name]}</strong> was recently created! try reloading the page to edit it</span>" #ENGLISH
    else
      @card = Card.new @args
      if @card.ok? :create
        render (request.xhr? ?
          {:partial=>'views/new', :locals=>{ :card=>@card }} : #ajax
          {:action=> 'new'} #normal
        )
      else
        render_denied('create')
      end
    end
  end

  # no longer in use, righ?
  #def denial
  #  render :template=>'/card/denied', :status => 403
  #end

  def create
    @card = Card.new params[:card]
    return render_denied('create') if !@card.ok? :create
    @card.save
    
    
    if params[:multi_edit] and params[:cards] and !@card.errors.present?
      @card.multi_create(params[:cards])
    end

    # according to rails / prototype docs:
    # :success: [...] the HTTP status code is in the 2XX range.
    # :failure: [...] the HTTP status code is not in the 2XX range.

    # however on 302 ie6 does not update the :failure area, rather it sets the :success area to blank..
    # for now, to get the redirect notice to go in the failure slot where we want it,
    # we've chosen to render with the (418) 'teapot' failure status:
    # http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
    handling_errors do
      @thanks = Wagn::Hook.call( :redirect_after_create, @card ).first ||
        @card.setting('thanks')
      case
        when @thanks.present?;               ajax_redirect_to @thanks
        when @card.ok?(:read) && main_card?; ajax_redirect_to url_for_page( @card.name )
        when @card.ok?(:read);               render_show
        else                                 ajax_redirect_to "/"
      end
    end
  end

  def ajax_redirect_to url
    @redirect_location = url
    @message = "Create Successful!"
    render :action => "ajax_redirect", :status => 418
  end


  #--------------( editing )

  def edit
    if ['name','type','codename'].member?(params[:attribute])
      render :partial=>"card/edit/#{params[:attribute]}"
      #render_cardedit(:part=>params[:attribute])
    end
  end

  def update
    card_args=params[:card] || {}
    #fail "card params required" unless params[:card] or params[:cards]

    # ~~~ REFACTOR! -- this conflict management handling is sloppy
    Rails.logger.debug "update set current_revision #{@card.name}, #{@card.current_revision}"
    @current_revision_id = @card.current_revision.id
    old_revision_id = card_args.delete(:current_revision_id) || @current_revision_id
    if old_revision_id.to_i != @current_revision_id.to_i
      changes  # FIXME -- this should probably be abstracted?
      @no_changes_header = true
      @changes = render_to_string :action=>'changes'
      return render( :action=>:edit_conflict )
    end
    # ~~~~~~  /REFACTOR ~~~~~ #

    @card_args = card_args

    case
    when params[:multi_edit]; @card.multi_update(params[:cards])
    when card_args[:type]; @card.typecode=Cardtype.classname_for(card_args.delete(:type)); @card.save
      #can't do this via update attributes: " Can't mass-assign these protected attributes: type"
      #might be addressable via attr_accessors?
    else;   @card.update_attributes(card_args)
    end

    if @card.errors.on(:confirmation_required) && @card.errors.map {|e,f| e}.uniq.length==1
      # If there is confirmation error and *only* that error
      @confirm = (@card.confirm_rename=true)
      @card.update_referencers = true
      return render(:partial=>'card/edit/name', :status=>200)
      #return render_cardedit(:part=>:name, :status=>200)
    end

    handling_errors do
      @card = Card.fetch(@card.name)   # wtf?
      request.xhr? ? render_update_slot(render_show_text, "updated #{@card.name}") : render_show
    end
  end

  def quick_update
    @card.update_attributes! params[:card]
    handling_errors do
      render(:text=>'Success')
    end
  end

  def update_codename
    return unless System.always_ok?
    old_codename = @card.extension.class_name
    @card.extension.update_attribute :class_name, params[:codename]
    Card.update_all( {:type=> params[:codename] }, ["type = ?", old_codename])
    handling_errors do
      render(:text => 'Success' )
    end
  end

  def save_draft
    @card.save_draft( params[:card][:content] )
    render(:update) do |page|
      page.wagn.messenger.log("saved draft of #{@card.name}")
    end
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
    render_update_slot render_to_string(:text=>render_show_text), "comment saved"
  end

  def rollback
    load_card_and_revision
    @card.update_attributes! :content=>@revision.content
    render_update_slot render_to_string(:text=>render_show_text), "content rolled back"
  end

  #------------( deleting )

  def remove
    @card.confirm_destroy = params[:card][:confirm_destroy] if params[:card]
    captcha_ok = captcha_required? ? verify_captcha : true
    return render_update_slot( render_to_string(:partial=>'confirm_remove'), "confirmation required") unless captcha_ok

    @card.destroy

    if @card.errors.on(:confirmation_required)
      return render_update_slot( render_to_string(:partial=>'confirm_remove'), "errors on confirmation")
    end

    handling_errors do
      discard_locations_for(@card)
      render_update_slot do |page,target|
        if main_card?
          flash[:notice] =  "#{@card.name} removed"
          page.wagn.messenger.note "#{@card.name} removed."
          page.redirect_to previous_location
        else
          target.replace %{<div class="faint">#{@card.name} was just removed</div>}
          page.wagn.messenger.note( "#{@card.name} removed. ")
        end
      end
    end
  end

  #---------------( tabs )

  def view
    render_show
  end

  def open
    params[:view] = :open
    render_show
  end

  def options
    @extension = @card.extension
  end

  def changes
    load_card_and_revision
    @show_diff = (params[:mode] != 'false')
    @previous_revision = @card.previous_revision(@revision)
  end

  def related
    sources = [@card.typename,nil]
    sources.unshift '*account' if @card.extension_type=='User'
    @items = sources.map do |root|
      c = Card.fetch((root ? "#{root}+" : '') +'*related')
      c && c.item_names
    end.flatten.compact
#    @items << 'config'
    @current = params[:attribute] || @items.first.to_key
  end

  #------------------( views )

  #  I don't think these are used any more.  If they are, they shouldn't be!
  #
  #[:open_missing, :closed_missing].each do |method|
  #  define_method( method ) do
  #    load_card
  #    params[:view] = method
  #    if id = params[:replace]
  #      render_update_slot do |page, target|
  #        target.update render_to_string(:action=>'show')
  #      end
  #    else
  #      render_show
  #    end
  #  end
  #end




  #-------- ( MISFIT METHODS )
  def watch
    watchers = Card.fetch_or_new( @card.name + "+*watchers", :skip_virtual=>true, :type => 'Pointer' )
    watchers.add_item User.current_user.card.name
    #flash[:notice] = "You are now watching #{@card.name}"
    request.xhr? ? render(:inline=>%{<%= get_slot.watch_link %>}) : view
  end

  def unwatch
    watchers = Card.fetch_or_new( @card.name + "+*watchers", :skip_virtual=>true )
    watchers.drop_item User.current_user.card.name
    #flash[:notice] = "You are no longer watching #{@card.name}"
    request.xhr? ? render(:inline=>%{<%= get_slot.watch_link %>}) : view
  end

  def auto_complete_for_navbox
    if @stub = params['navbox']
      @items = Card.search( :complete=>@stub, :limit=>8, :sort=>'name' )
      render :inline=> "<%= navbox_result @items, 'name', @stub %>"
    else
      render :inline=> ''
    end
  end

  def auto_complete_for_card_name
    complete = ''
    # from pointers, the partial text is from fields called  pointer[N]
    # from the goto box, it is in card[name]
    params.keys.each do |key|
      complete = params[key] if key.to_s == 'name'
      next unless key.to_s =~ /card|pointer/
      complete = params[key].values[0]
    end
    complete = complete.to_s
    # FIXME - shouldn't we bail here if we don't have anything to complete?

    options_card =
      (!params[:id].blank? and
       (pointer_card = Card.fetch_or_new(params[:id], :skip_defaults=>true, :type=>'Pointer')) and
       pointer_card.options_card)

    search_args = {  :complete=>complete, :limit=>8, :sort=>'name' }
    @items = options_card ? options_card.item_cards(search_args) : Card.search(search_args)

    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end


  # this should all happen in javascript
  
  def add_field # for pointers only
    load_card if params[:id]
    @card ||= Card.new(:type=>'Pointer', :skip_defaults=>true)
    #render :partial=>'types/pointer/field', :locals=>params.merge({:link=>:add,:card=>@card})
    render(:text => Wagn::Renderer.new(@card, :context=>params[:eid]).render(:field, :link=>:add, :index=>params[:index]) )
  end

end

