class CardController < ApplicationController
  helper :wagn, :card 
  layout :ajax_or_not
  cache_sweeper :card_sweeper
  before_filter :load_card!, :except => [ :new, :create, :show, :index  ]
  before_filter :load_card, :only=>[ :new, :create ]

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
    @card = Card.create! params[:card]
    # prevent infinite redirect loop
    fail "Card creation failed"  unless Card.find_by_name( @card.name )
    # FIXME: it would make the tests nicer if we did a real redirect instead of rjs
  end 

  def index
    redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(System.site_name)
  end

  def new
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
    @card.destroy!
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
      # the user has permission to create a card.  If not, then we should 
      # redirect anonymous users to the login page with some sort of message
      # explaining why they're there.  And there should be a different way of 
      # handling users who are logged in but lack permission to create cards 
      # (it would be nice to catch them before they leave the referring page,
      # but there needs to be a net anyway, and besides this is currently still
      # just a theoretical case)
      redirect_to :controller=>'account', :action=>'login'
    end
  end

  def update 
    if @card.update_attributes params[:card]     
      render :action=>'view'
    else
      render :action=>'edit'
    end
  end


end
