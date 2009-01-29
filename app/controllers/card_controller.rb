class CardController < ApplicationController

  helper :wagn, :card 
  layout :default_layout
  cache_sweeper :card_sweeper

  before_filter :create_ok, :only=>[ :new, :create ]

  before_filter :load_card!, :only=>[
    :changes, :comment, :denied, :edit, :edit_conflict, :edit_name, 
    :edit_type, :options, :quick_update, :related, :remove, :rollback, 
    :save_draft, :to_edit, :update
  ]

  before_filter :load_card_with_cache, :only => [:line, :view, :to_view ]
  
  before_filter :edit_ok,   :only=>[ :edit, :edit_name, :edit_type, :update, :rollback, :save_draft] 
  before_filter :remove_ok, :only=>[ :remove ]
  
  #caches_action :show, :view, :to_view

  protected
  def action_fragment_key(options)
    roles_key = User.current_user.all_roles.map(&:id).join('-')
    global_serial = Cache.get('GlobalSerial') #Time.now.to_f }
    key = url_for(options).split('://').last + "/#{roles_key}" + "/#{global_serial}" + 
      "/#{default_layout}"
  end
       

  public    
  # weird that this is public
  def cache_action?(action_name)
    if !flash[:notice].blank? || !flash[:warning].blank? || !flash[:error].blank?
      #warn "flash present"
      return false 
    else 
      true
    end
 	end
   

  #----------( Special cards )
  
  def index
    if card = CachedCard.get_real('*home')
      redirect_to '/'+ card.content
    else
      redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(System.site_name)
    end
  end

  def mine
    redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(User.current_user.card.name)
  end
          
  def my_name                                              
    self.class.layout nil
    render :text=>User.current_user.card.name
    self.class.layout :default_layout
  end

  #----------------( MODIFYING CARDS )
  
  #----------------( creating)                                                               
  def new
    args = (params[:card] ||= {})
    
    # handle cardtype param:  for /new/:cardtype shortcut in routes
    if params[:cardtype]  
      args[:type] ||= params[:cardtype]
    end
    
    # don't pass a blank type as argument
    # look up other types in case Cardtype name is given instead of ruby type
    if args[:type]
      if args[:type].blank?
        args.delete(:type) 
      elsif ct=CachedCard.get_real(args[:type])    
        args[:type] = ct.name 
      end
    end

    # if given a name of a card that exists, got to edit instead
    if args[:name] and card = CachedCard.get( args[:name] ) and !card.new_record?
      if request.xhr?
        return render_update_slot do |page,target|
          target.replace "<span class=\"faint\">Oops, <strong>#{args[:name]}</strong> was recently created! try reloading the page to edit it</span>"
        end
      end
    end

      
    @card = Card.new args                   
    if request.xhr?
      render_update_slot do |page,target|
        # ie
        # permissions
        target.replace render_to_string :partial => 'card/new', :locals=>{ :card=>@card }
      end 
    else
      render :action=> 'new'
    end
  end
  
  def create                 
    if !Card.new(params[:card]).cardtype.ok?(:create)  
      render :template => '/card/denied', :status => 403  
      return
    end
    
    @card = Card.create params[:card]
    if params[:multi_edit] and params[:cards]
      User.as(:admin) if @card.type == 'InvitationRequest'
      @card.multi_update(params[:cards])
    end   

    # double check to prevent infinite redirect loop
    fail "Card creation failed"  unless Card.find_by_name( @card.name )
    
      
    if !@card.errors.empty?
      render :action=>'new', :status => 422
    elsif main_card?   
      render :text=> url_for_page(@card.name), :status=>302
    else
      render :action=>'show'
    end
  end 
  
  #--------------( editing )
  
  def edit 
    @add_slot = nil
    if params[:card] and @card.type=params[:card][:type]  
      @card.save!
      @card = Card.find(card.id)
    end
  end
  
  def edit_name             
    @old_card = @card.clone
    if !params[:card]
    elsif @card.update_attributes params[:card]
      render_update_slot render_to_string(:action=>'edit')
    elsif @card.errors.on(:confirmation_required) && @card.errors.map {|e,f| e}.uniq.length==1
      @confirm = true   
      @card.confirm_rename=true
      @card.update_link_ins = (@card.update_link_ins=='true')
#      render :action=>'edit', :status=>200
    else          
      # don't report confirmation required as error in a case where the interface will let you fix it.
      @card.errors.instance_variable_get('@errors').delete('confirmation_required')
      @request_type='html'
      render_card_errors(@card)
    end
  end
  
  
  def update     
    old_rev_id = params[:card] ? params[:card].delete(:current_revision_id)  : nil
    #warn "old rev id = #{old_rev_id}; current = #{@card.current_revision.id} "
    ##FIXME -- this should be taken care of in transclusions, too.
    if params[:card] and params[:card][:content] and (old_rev_id.to_i != @card.current_revision.id.to_i)
      changes  # FIXME -- this should probably be abstracted?
      @no_changes_header = true
      @changes = render_to_string :action=>'changes' 
      return render( :action=>:edit_conflict )
    end 
    if params[:multi_edit]
      @card.multi_update(params[:cards])
    else
      @card.update_attributes! params[:card]     
    end

    return render_card_errors(@card) unless @card.errors.empty?
    render_update_slot render_to_string(:action=>'show')
  end

  def quick_update
    @card.update_attributes! params[:card]
    @card.errors.empty? ? render(:text=>'Success') : render_card_errors(@card)    
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
      @author = "[[#{User.current_user.card.name}]]"
    end
    @comment.gsub! /\n/, '<br/>'
    @card.comment = "<hr>#{@comment}<br/><p><em>&nbsp;&nbsp;--#{@author}.....#{Time.now}</em></p>"
    @card.save!   
    view = render_to_string(:action=>'show')
    render_update_slot view
  end

  def rollback
    load_card_and_revision
    @card.update_attributes! :content=>@revision.content
    render :action=>'show'
  end  

  #------------( deleting )

  def remove  
    if params[:card]
      @card.confirm_destroy = params[:card][:confirm_destroy]
    end
    if @card.destroy     
      discard_locations_for(@card)
      render_update_slot do |page,target|
        if @context=="main_1"
          page.wagn.messenger.note "#{@card.name} removed."
          page.redirect_to previous_location
          flash[:notice] =  "#{@card.name} removed"
        else 
          target.replace %{<div class="faint">#{@card.name} was just removed</div>}
          page.wagn.messenger.note( "#{@card.name} removed. ")  
        end
      end
    elsif @card.errors.on(:confirmation_required)
      render_update_slot render_to_string(:partial=>'confirm_remove')
    else
      render_card_errors(@card)
    end
  end

  #---------( VIEWING CARDS )
  
  def show
    # record this as a place to come back to.
    location_history.push(request.request_uri) if request.get?
    
    @card_name = Cardname.unescape(params['id'] || '')
    if (@card_name.nil? or @card_name.empty?) then    
      @card_name = System.site_name
      #@card_name = System.deck_name
    end             
    @card = CachedCard.get(@card_name)
        
    if @card.new_record? && ! @card.phantom?
      params[:card]={:name=>@card_name, :type=>params[:type]}
      if Cardtype.createable_cardtypes.empty? 
        return render :action=>'missing'
      else
        return self.new
      end
    end                                                                                  
    return unless view_ok # if view is not ok, it will render denied. return so we dont' render twice
    
    # rss causes infinite memory suck in rails 2.1.2.  
    unless Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR >=2
      respond_to do |format|
        format.rss { raise("Sorry, RSS is broken in rails < 2.2") }
        format.html {}
      end
    end 
  end

  #---------------( tabs )

  def view
    render :action=>'show'
  end   
  
  def open
    render :action=>'show'
  end

  def to_view
    params[:view]='open'
    render_update_slot do |page, target|
      target.update render_to_string(:action=>'show')
#      page << "Wagn.line_to_paragraph(#{slot.selector})"
    end
  end
             
  def to_edit
    render_update_slot do |page, target|
      target.update render_to_string(:action=>'edit')
      page << "Wagn.line_to_paragraph(#{slot.selector})"
    end
  end

  def options
    @extension = card.extension
  end

  def changes
    load_card_and_revision
    @show_diff = (params[:mode] != 'false')
    @previous_revision = @card.previous_revision(@revision)
  end
    
  [:open_missing, :closed_missing].each do |method|
    define_method( method ) do
      load_card
      params[:view] = method
      if id = params[:replace]
        render_update_slot do |page, target|
          target.update render_to_string(:action=>'show')
        end
      else
        render :action=>'show'
      end
    end
  end

    
    
    
  #-------- ( MISFIT METHODS )  
    
  def auto_complete_for_card_name
    complete = ''
    params.keys.each do |key|
      complete = params[key] if key.to_s == 'name'
      next unless key.to_s =~ /card|pointer/ 
      complete = params[key].values[0]
    end

    if !params[:id].blank? && (card = Card["#{params[:id].tag_name}+*options"]) && card.type=='Search'
      @items = card.search( :complete=>complete, :limit=>8, :sort=>'alpha')
    else
      @items = Card.search( :complete=>complete, :limit=>8, :sort=>'alpha' )
    end
    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end
  
  # doesn't really seem to fit here.  may want to add new controller if methods accrue?        
  def add_field # for pointers only
    load_card! if params[:id]
    render :partial=>'cardtypes/pointer/field', :locals=>params.merge({:link=>"",:card=>@card})
  end
end

