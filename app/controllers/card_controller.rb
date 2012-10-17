# -*- encoding : utf-8 -*-
class CardController < ApplicationController
  helper :wagn

  before_filter :index_preload, :only=> [ :index ]
  before_filter :read_file_preload, :only=> [ :read_file ]

  before_filter :load_card
  before_filter :read_ok,   :only=> [ :read_file ]


  def create
    if @card.save
      success
    else
      errors
    end
  end

  def read
    save_location # should be an event!
    show
  end

  def update
    @card = @card.refresh if @card.frozen? # put in model
    case
    when @card.new_card?                          ;  create
    when @card.update_attributes( params[:card] ) ;  success
    else                                             errors
    end
  end

  def delete
    @card = @card.refresh if @card.frozen? # put in model
    @card.confirm_destroy = params[:confirm_destroy]
    @card.destroy

    return show(:delete) if @card.errors[:confirmation_required].any?

    discard_locations_for(@card)

    success 'REDIRECT: TO-PREVIOUS'
  end
  

  def index
    read
  end # handle in load card?


  def read_file
    show_file
  end #FIXME!  move to pack
  



  ## the following methods need to be merged into #update

  def save_draft
    if @card.save_draft params[:card][:content]
      render :nothing=>true
    else
      errors
    end
  end

  def comment
    raise Wagn::BadAddress, "comment without card" unless params[:card]
    # this previously failed unless request.post?, but it is now (properly) a PUT.
    # if we enforce RESTful http methods, we should do it consistently,
    # and error should be 405 Method Not Allowed

    @card = @card.refresh if @card.frozen?

    author = Session.user_id == Card::AnonID ?
        "#{session[:comment_author] = params[:card][:comment_author]} (Not signed in)" : "[[#{Session.user.card.name}]]"
    comment = params[:card][:comment].split(/\n/).map{|c| "<p>#{c.strip.empty? ? '&nbsp;' : c}</p>"} * "\n"
    @card.comment = "<hr>#{comment}<p><em>&nbsp;&nbsp;--#{author}.....#{Time.now}</em></p>"
    
    if @card.save
      show
    else
      errors
    end
  end

  def rollback
    @card = @card.refresh if @card.frozen?
    revision = @card.revisions[params[:rev].to_i - 1]
    @card.update_attributes! :content=>revision.content
    @card.attachment_link revision.id
    show
  end


  def watch
    watchers = @card.trait_card(:watchers )
    watchers = watchers.refresh if watchers.frozen?
    myname = Card[Session.user_id].name
    watchers.send((params[:toggle]=='on' ? :add_item : :drop_item), myname)
    ajax? ? show(:watch) : read
  end






  #-------- ( ACCOUNT METHODS )

  def update_account

    if params[:save_roles]
      role_card = @card.trait_card :roles
      role_card.ok! :update
      
      role_hash = params[:user_roles] || {}
      role_card = role_card.refresh if role_card.frozen?
      role_card.items= role_hash.keys.map &:to_i
    end

    account = @card.to_user
    if account and account_args = params[:account]
      unless Session.as_id == @card.id and !account_args[:blocked]
        @card.trait_card(:account).ok! :update
      end 
      account.update_attributes account_args
    end

    if account && account.errors.any?
      account.errors.each do |field, err|
        @card.errors.add field, err
      end
      errors
    else
      show
    end
  end

  def create_account
    @card.trait_card(:account).ok! :create
    email_args = { :subject => "Your new #{Card.setting :title} account.",   #ENGLISH
                   :message => "Welcome!  You now have an account on #{Card.setting :title}." } #ENGLISH
    @user, @card = User.create_with_card(params[:user],@card, email_args)
    raise ActiveRecord::RecordInvalid.new(@user) if !@user.errors.empty?
    #@account = User.new(:email=>@user.email)
#    flash[:notice] ||= "Done.  A password has been sent to that email." #ENGLISH
    params[:attribute] = :account
    show :options
  end




  private

  #-------( FILTERS )

  def read_file_preload
    #warn "show preload #{params.inspect}"
    params[:id] = params[:id].sub(/(-(#{Card::STYLES*'|'}))?(-\d+)?(\.[^\.]*)?$/) do
      @style = $1.nil? ? 'original' : $2
      @rev_id = $3 && $3[1..-1]
      params[:format] = $4[1..-1] if $4
      ''
    end
  end

  def index_preload
    Session.no_logins? ?
      redirect_to( Card.path_setting '/admin/setup' ) :
      params[:id] = (Card.setting(:home) || 'Home').to_cardname.url_key
  end


  def load_card
    @card = case params[:id]
      when '*previous'   ; return wagn_redirect( previous_location )  
      when /^\~(\d+)$/   ; Card.fetch $1.to_i
      when /^\:(\w+)$/   ; Card.fetch $1.to_sym
      else
        opts = params[:card] ? params[:card].clone : {}
        opts[:type] ||= params[:type] # for /new/:type shortcut.  we should fix and deprecate this.
        name = params[:id] ? Wagn::Cardname.unescape( params[:id] ) : opts[:name]
        
        if @action == 'create'
          # FIXME we currently need a "new" card to catch duplicates (otherwise #save will just act like a normal update)
          # I think we may need to create a "#create" instance method that handles this checking.
          # that would let us get rid of this...
          opts[:name] ||= name
          Card.new opts
        else
          Card.fetch_or_new name, opts
        end
      end
      
    Wagn::Conf[:main_name] = params[:main] || (@card && @card.name) || ''
    true
  end


  def success(default_target='TO-CARD')
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
    when  redirect        ; wagn_redirect ( Card===target ? wagn_path(target) : target )
    when  String===target ; render :text => target
    else  @card = target  ; show
    end
  end

end

