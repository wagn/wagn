class CardController < ApplicationController
  helper :wagn, :card 
  layout :ajax_or_not
  cache_sweeper :card_sweeper
  before_filter :load_card!, :except => [ :new, :create, :show, :index  ]

  before_filter :edit_ok,   :only=>[ :edit, :update, :save_draft, :rollback, :save_draft] 
  before_filter :create_ok, :only=>[ :new, :create ]
  before_filter :remove_ok, :only=>[ :remove, :confirm_remove ]

  def changes
    load_card_and_revision
    @show_diff = (params[:mode] != 'false')
    @previous_revision = @card.previous_revision(@revision)
  end
  
  def comment
    @comment = params[:card][:comment]        
    # FIXME this should only let the name be specified if user is anonymous. no faking! 
    @author = params[:card][:comment_author] || User.current_user.card.name
    @card.comment = "<hr>#{@comment}<br>--#{@author}.....#{Time.now}<br>"
    @card.save!
  end 
    
  def create         
    @card = Card.create params[:card]
    if @card.errors.empty?
      # double check to prevent infinite redirect loop
      fail "Card creation failed"  unless Card.find_by_name( @card.name )
      # FIXME: it would make the tests nicer if we did a real redirect instead of rjs
      render :update do |page|
        page.redirect_to url_for_page(@card.name)
      end
    else
      render :update do |page|
        page.replace_html slot.id(:notice), :partial=>'trouble'
        page.visual_effect :highlight, slot.id(:notice)
      end
    end
  end 
  
  def edit
    if updating_type?
      @card.type=params[:card][:type]  
      @card.save!
      @card = Card.find(@card.id)
      @card.content = params[:card][:content]
    end
  end

  def index
    redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(System.site_name)
  end

  def new  
    @card = Card.new params[:card]
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
      session[:return_stack].pop  #dirty hack so we dont redirect to ourself after delete
      render :update do |page|
        if @context=='main'
          page['alerts'].replace "#{@card.name} removed. Redirecting to #{previous_page}..."
          page.redirect_to url_for_page(previous_page)
        else 
          page.wagn.messenger.note( "#{@card.name} removed. ")  
          page.wagn.lister.update()
        end
      end
    elsif @card.errors.on(:confirmation_required)
      render :update do |page|
        page.replace_html slot.id(:remove), :partial=>'confirm_remove'
      end     
    else
      render :update do |page|
        page.replace_html slot.id(:notice), "#{@card.errors.full_messages.join(',')}"
      end
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
    if @card_name.nil? or @card_name.empty?
      return redirect_to( :controller=>'card',:action=>'show', :id=>Cardname.escape(System.site_name))
    end             
    
    if (@card = Card.find_by_name( @card_name )) 
      @card.ok! :read
      remember_card @card
      # FIXME: I'm sure this is broken now that i've refactored..                               
      respond_to do |format|
        format.html { render :action=>'show' }
        format.json {
          render_jsonp :partial =>'card/view', 
            :locals=>{ :card=> @card, :context=>"main",:action=>"view"}
        }
      end
    elsif User.current_user
      redirect_to :controller=>'card', :action=>'new', :params=>{ 'card[name]'=>@card_name }
    else
      # FIXME this logic is not right.  We should first check whether 
      # the user has permission to create any cards (or, if specified, to create cards of this type)  If not, then we should 
      # redirect unsigned in users to a page explaining that they've been linked to a card that doesn't
      # exist and offering them the option to sign in or request an invitation.
      # 
      # Users who are logged in but lack permission to create cards under these conditions
      # should have a similar explanation, but without the login options.
      
      redirect_to :controller=>'account', :action=>'login'
    end
  end

  def update 
    if @card.update_attributes params[:card]     
      render :update do |page|
        # page.redirect_to slot.url_for('card/view')
        page.replace_html slot.id, :partial=>'view', 
          :locals=>{:card=>@card, :context=>@context, :action=>'view'}
      end
      #render :action=>'view'
    else
      render :action=>'edit', :status=>422
    end
  end


end
