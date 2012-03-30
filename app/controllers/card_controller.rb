# -*- encoding : utf-8 -*-
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
      render_errors
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
    #warn Rails.logger.info("show me")
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

    if @card.ok? :create
      render_show :new
    else
      render_denied 'create'
    end
  end


  #--------------( UPDATE )


  def update
    @card = @card.refresh if @card.frozen?
    if @card.update_attributes params[:card]
      render_success
    else
      render_errors
    end
  end


  ## the following three methods need to be merged into #update

  def save_draft
    if @card.save_draft params[:card][:content]
      render :nothing=>true
    else
      render_errors
    end
  end

  def comment
    raise Wagn::BadAddress unless params[:card]
    # this previously failed unless request.post?, but it is now (properly) a PUT.
    # if we enforce RESTful http methods, we should do it consistently,
    # and error should be 405 Method Not Allowed

    @card = @card.refresh if @card.frozen?

    author = Card.user_id == Card::AnonID ?
        "#{session[:comment_author] = params[:card][:comment_author]} (Not signed in)" :
        "[[#{Card[Card.user_id].name}]]"
    comment = params[:card][:comment].split(/\n/).map{|c| "<p>#{c.empty? ? '&nbsp;' : c}</p>"}.join("\n")
    @card.comment = "<hr>#{comment}<p><em>&nbsp;&nbsp;--#{author}.....#{Time.now}</em></p>"
    
    if @card.save
      render_show
    else
      render_errors
    end
  end

  def rollback
    @card = @card.refresh if @card.frozen?
    revision = @card.revisions[params[:rev].to_i - 1]
    @card.update_attributes! :content=>revision.content
    @card.attachment_link revision.id
    render_show
  end



  #------------( DELETE )

  def remove
    @card = @card.refresh if @card.frozen?
    @card.confirm_destroy = params[:confirm_destroy]
    @card.destroy

    return render_show(:remove) if @card.errors[:confirmation_required].any?

    discard_locations_for(@card)

    render_success 'REDIRECT: TO-PREVIOUS'
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
      render_errors
    else
      render_show
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
    render_show :options
  end


  #-------- ( MISFIT METHODS )


  def watch
    watchers = @card.trait_card(:watchers )
    watchers = watchers.refresh if watchers.frozen?
    myname = Card[Card.user_id].name
    watchers.send((params[:toggle]=='on' ? :add_item : :drop_item), myname)
    ajax? ? render_show(:watch) : view
  end


  private

  #-------( FILTERS )

  def show_file_preload
    #warn "show preload #{params.inspect}"
    params[:id] = params[:id].sub(/(-(#{Card::STYLES*'|'}))?(-\d+)?(\.[^\.]*)?$/) do
      @style = $1.nil? ? 'original' : $2
      @rev_id = $3 && $3[1..-1]
      params[:format] = $4[1..-1] if $4
      ''
    end
  end


  def index_preload
    Card.no_logins? ?
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
      raise Wagn::NotFound
    when @card.known? # default case
      @card
    when params[:view] =~ /rule|missing/
      # FIXME this is a hack so that you can view load rules that don't exist.  need better approach
      # (but this is not tested; please don't delete without adding a test)
      @card
    when [nil, 'html'].member?(params[:format]) && @card.ok?(:create) 
      params[:card] = { :name=>@card.name, :type=>params[:type] }
      self.new
      false
    else
      raise Wagn::NotFound
    end
  end

  def load_card
    #warn Rails.logger.info("load_card #{params.inspect}")
    return @card=nil unless id = params[:id]
#    ActiveSupport::Notifications.instrument 'wagn.load_card', :message=>"load #{id}" do
      case id
      when /^\~(\d+)$/
        @card=Card.find($1)
        @card.include_set_modules
        return @card
      when '*previous'
        @card = '*previous'
      else
        @card = Card.fetch_or_new( Wagn::Cardname.unescape(id), 
          (params[:card] ? params[:card].clone : {} )
        )
      end
#    end
  end


  #---------( RENDERING )


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
    when  redirect        ; wagn_redirect ( Card===target ? wagn_path(target) : target )
    when  String===target ; render :text => target
    else  @card = target  ; render_show
    end
  end

end

