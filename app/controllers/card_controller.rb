class CardController < ApplicationController
  helper :wagn, :card 
  layout :ajax_or_not
  cache_sweeper :card_sweeper
  before_filter :load_card!, :except => [ :auto_complete_for_card_name, :line, :view, :to_view, :test, :new, :create, :show, :index, :mine, :missing ]
  before_filter :load_card_with_cache, :only => [:line, :view, :to_view ]

  before_filter :edit_ok,   :only=>[ :update, :save_draft, :rollback, :save_draft] 
  before_filter :create_ok, :only=>[ :new, :create ]
  before_filter :remove_ok, :only=>[ :remove ]
  
  def auto_complete_for_card_name
    complete = ''
    params.keys.each do |key|
      complete = params[key] if key.to_s == 'name'
      next unless key.to_s =~ /card|pointer/ 
      complete = params[key].values[0]
    end

    if !params[:id].blank? && card = Card["#{params[:id].tag_name}+*options"]
      @items = card.search( :complete=>complete, :limit=>8, :sort=>'alpha')
    else
      @items = Card.search( :complete=>complete, :limit=>8, :sort=>'alpha' )
    end
    render :inline => "<%= auto_complete_result @items, 'name' %>"
  end
     
  def test
    #render_update_slot_element('notice', 'gooooood stuff')
  end
                                                                
  def changes
    load_card_and_revision
    @show_diff = (params[:mode] != 'false')
    @previous_revision = @card.previous_revision(@revision)
  end
  
  def comment
    raise(Wagn::NotFound,"Action comment should be post with card[:comment]") unless request.post? and params[:card]
    @comment = params[:card][:comment];
    if User.current_user.login == 'anon'
      @author = params[:card][:comment_author]
      session[:comment_author] = @author
      @author = "#{@author} (Not signed in)"
    else
      @author = User.current_user.card.name
    end
    @comment.gsub! /\n/, '<br/>'
    @card.comment = "<hr>#{@comment}<br/><p><em>&nbsp;&nbsp;--#{@author}.....#{Time.now}</em></p>"
    @card.save!   
    view = render_to_string(:action=>'view')
    render_update_slot view
  end 
    
  def create         
    @card = Card.create! params[:card]
    #return render_errors unless @card.errors.empty?
    # double check to prevent infinite redirect loop
    fail "Card creation failed"  unless Card.find_by_name( @card.name )
    # FIXME: it would make the tests nicer if we did a real redirect instead of rjs
    render :update do |page|
      page.redirect_to url_for_page(@card.name)
    end
  end 
  
  def create_template
    @card = Card.create! :name=>@card.name+"+*template"
    render_update_slot_element 'template',  
      render_to_string( :inline=>%{<%= get_slot.render(:view, :wrap=>true, :add_javascript=>true ) %>})
  end
  
  def edit 
    if @card.ok?(:edit) 
      @card = handle_cardtype_update(@card)
    else
      render :action=>'denied', :status=>403
    end
  end

  def index
    redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(System.site_name)
#    redirect_to :controller=>'card',:action=>'show', :id=>System.deck_name
  end
 
  def mine
    redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(User.current_user.card.name)
  end

  def new
    @card = Card.new params[:card] 
    @card.content = strip_tags(@card.content) unless (card.class.superclass.to_s=='Card::Basic' or card.type=='Basic')
    
    @card.send(:set_defaults)
    
    if @card.type == 'User'
      redirect_to :controller=>'account', :action=>'invite'
    end
    #if request.post?
    #  render :partial=>'new_editor'
    #end
  end

  def rollback
    load_card_and_revision
    @card.update_attributes! :content=>@revision.content
    render :action=>'view'
  end  
  
  def remove  
    if params[:card]
      @card.confirm_destroy = params[:card][:confirm_destroy]
    end
    if @card.destroy     
      #dirty hack so we dont redirect to ourself after delete
      session[:return_stack].pop if ( session[:return_stack] and session[:return_stack].last==@card.id )
      render_update_slot do |page,target|
        if @context=="main_1"
          page.wagn.messenger.note "#{@card.name} removed. Redirecting to #{previous_page}..."
          page.redirect_to url_for_page(previous_page)
          flash[:notice] =  "#{@card.name} removed"
        else 
          target.replace %{<div class="faint">#{@card.name} was just removed</div>}
          page.wagn.messenger.note( "#{@card.name} removed. ")  
        end
      end
    elsif @card.errors.on(:confirmation_required)
      render_update_slot render_to_string(:partial=>'confirm_remove')
    else
      render_errors
    end
  end

  def rollback
    load_card_and_revision
    @card.update_attributes! :content=>@revision.content
    render :action=>'edit'
  end  

  def save_draft
    @card.save_draft( params[:card][:content] )
    render(:update) do |page|
      page.wagn.messenger.log("saved draft of #{@card.name}")
    end
  end  

  def show
    @card_name = Cardname.unescape(params['id'] || '')
    if (@card_name.nil? or @card_name.empty?) then    
      @card_name = System.site_name
      #@card_name = System.deck_name
    end             
    @card = CachedCard.get(@card_name)
    
    if @card.new_record? && ! @card.phantom?
      action =  User.current_user.createable_cardtypes.empty? ? :missing : :new
      return redirect_to( :action=>action, :params=>{ 'card[name]'=>@card_name } )
    end                                                                                  
    remember_card @card
    # FIXME: I'm sure this is broken now that i've refactored..                               
    respond_to do |format|
      format.html { render :action=>'show' }
      format.json {
        @wadget = true
        render_jsonp :partial =>'card/view', 
          :locals=>{ :card=> @card, :context=>"main",:action=>"view"}
      }
    end
  end

  def to_view
    render_update_slot do |page, target|
      target.update render_to_string(:action=>'view')
      page << "Wagn.line_to_paragraph(#{slot.selector})"
    end
  end
             
  # FIXME?  this seems 
  def to_edit
    render_update_slot do |page, target|
      target.update render_to_string(:action=>'edit')
      page << "Wagn.line_to_paragraph(#{slot.selector})"
    end
  end


  def update     
    old_rev_id = params[:card] ? params[:card].delete(:current_revision_id)  : nil
    #warn "old rev id = #{old_rev_id}; current = #{@card.current_revision.id} "
    if params[:card] and params[:card][:content] and (old_rev_id.to_i != @card.current_revision.id.to_i)
      changes  # FIXME -- this should probably be abstracted?
      @no_changes_header = true
      @changes = render_to_string :action=>'changes' 
      return render( :action=>:edit_conflict )
    end  
    if @card.hard_content_template
      errors = false
      params[:cards].each_pair do |id, opts|
        card = Card.find(id)
        card.update_attributes(opts)
        if !card.errors.empty?
          card.errors.each do |field, err|
            @card.errors.add card.name, err
          end
        end
      end  
    else
      @card.update_attributes! params[:card]     
    end
    return render_errors unless @card.errors.empty?
    render_update_slot render_to_string(:action=>'view')
  end
          
  def add_field # for pointers only
    render :partial=>'cardtypes/pointer/field', :locals=>params.merge({:card=>@card})
  end
                                                    
  def options
    @extension = card.extension
  end
end
