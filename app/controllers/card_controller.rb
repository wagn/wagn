# -*- encoding : utf-8 -*-
class CardController < ApplicationController
  helper :wagn

  EDIT_ACTIONS = [ :update, :rollback, :save_draft, :watch, :create_account, :update_account ]
  LOAD_ACTIONS =  EDIT_ACTIONS + [ :read_file, :read, :index, :comment, :delete ]

  before_filter :index_preload, :only=> [ :index ]
  before_filter :read_file_preload, :only=> [ :read_file ]

  before_filter :load_card!, :only=>LOAD_ACTIONS
  before_filter :set_main

  #  before_filter :create_ok, :only=>[ :new, :create ]
  before_filter :read_ok,   :only=> LOAD_ACTIONS
  before_filter :update_ok, :only=> EDIT_ACTIONS
  before_filter :delete_ok, :only=>[ :delete ]


  #----------( CREATE )

  # this should be handled by #read
  def new
    args = params[:card] || {}
    args[:type] ||= params[:type] # for /new/:type shortcut

    @card = Card.new args

    if @card.ok? :create
      show :new
    else
      deny 'create'
    end
  end


  def create
    @card = Card.new params[:card]
    if @card.save
      success
    else
      errors
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

  def read
    save_location # should be an event!
    show
  end

  def read_file()  show_file         end
  def index()      read              end

  #--------------( UPDATE )


  def update
    @card = @card.refresh if @card.frozen?
    if @card.update_attributes params[:card]
      success
    else
      errors
    end
  end


  ## the following three methods need to be merged into #update

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
        "#{session[:comment_author] = params[:card][:comment_author]} (Not signed in)" : "[[#{Session.user.name}]]"
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



  #------------( DELETE )

  def delete
    @card = @card.refresh if @card.frozen?
    @card.confirm_destroy = params[:confirm_destroy]
    @card.destroy

    return show(:delete) if @card.errors[:confirmation_required].any?

    discard_locations_for(@card)

    success 'REDIRECT: TO-PREVIOUS'
  end


  #-------- ( ACCOUNT METHODS )

  def update_account
    account = @card.to_user

    if params[:save_roles]
      role_hash = params[:user_roles] || {}
      Card[account.card_id].trait_card(:roles).items= role_hash.keys
    end

    if account && params[:account]
      account.update_attributes(params[:account])
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
    # FIXME: or should this be @card.trait_card(:account).ok?
    Card['*account'].ok?(:create) && @card.ok?(:update)
    email_args = { :subject => "Your new #{Card.setting('*title')} account.",   #ENGLISH
                   :message => "Welcome!  You now have an account on #{Card.setting('*title')}." } #ENGLISH
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
      params[:id] = (Card.setting('*home') || 'Home').to_cardname.to_url_key
  end

  def set_main
    Wagn::Conf[:main_name] = params[:main] || (@card && @card.name) || '' # will be wagn.main ?
  end


  # --------------( LOADING ) ----------
  def load_card!
    load_card
    #warn Rails.logger.info("load_card! #{@card}")
    case
      when @card == '*previous'
        wagn_redirect previous_location
      
      when !@card || @card.name.nil? || @card.name.empty?  #no card or no name -- bogus request, deserves error
        raise Wagn::BadAddress, "requested card without identifier"
      
      when @card.known? # default case
        @card
      
      when params[:view] =~ /rule|missing/
        # FIXME this is a hack so that you can view load rules that don't exist.  need better approach
        # (but this is not tested; please don't delete without adding a test)
        @card
      
      when html? && @card.ok?(:create) 
        params[:card] = { :name=>@card.name, :type=>params[:type] }
        self.new
        false
      
      else
        raise Wagn::NotFound, "unknown card: #{@card.name}"
    end
  end

  def load_card
    @card = case params[:id]
      when nil           ; nil
      when /^\~(\d+)$/   ; Card.fetch $1.to_i
      when /^\:(\w+)$/   ; Card.fetch $1.to_sym    
      when '*previous'   ; '*previous' # flag for redirect
      else
        name = Wagn::Cardname.unescape params[:id]
        opts = params[:card] ? params[:card].clone : {}
        Card.fetch_or_new name, opts
      end
  end


  #---------( RENDERING )


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

