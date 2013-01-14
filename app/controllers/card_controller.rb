# -*- encoding : utf-8 -*-

require_dependency 'cardlib'

class CardController < ApplicationController
  include Wagn::Sets::CardActions

  helper :wagn

  before_filter :index_preload, :only=> [ :index ]
  before_filter :read_file_preload, :only=> [ :read_file ]

  before_filter :load_card
  before_filter :refresh_card, :only=> [ :create, :update, :delete, :comment, :rollback ]
  before_filter :read_ok,      :only=> [ :read_file ]

  attr_reader :card

  def create
    #warn "create #{params.inspect}, #{card.inspect} if #{card && !card.new_card?}, nc:#{card.new_card?}"

    process_create
  end

  def read
    process_read
  end

  def update
    process_update
  end

  def delete
    process_delete
  end


  def index
    read
  end # handle in load card?


  def read_file
    show_file
  end #FIXME!  move to pack


  def action_error *a
    warn "action_error #{a.inspect}"
  end


  ## the following methods need to be merged into #update

  def save_draft
    if card.save_draft params[:card][:content]
      render :nothing=>true
    else
      render_errors
    end
  end

  def comment
    raise Wagn::BadAddress, "comment without card" unless params[:card]
    # this previously failed unless request.post?, but it is now (properly) a PUT.
    # if we enforce RESTful http methods, we should do it consistently,
    # and error should be 405 Method Not Allowed

    author = Account.user_id == Card::AnonID ?
        "#{session[:comment_author] = params[:card][:comment_author]} (Not signed in)" : "[[#{Account.user.card.name}]]"
    comment = params[:card][:comment].split(/\n/).map{|c| "<p>#{c.strip.empty? ? '&nbsp;' : c}</p>"} * "\n"
    card.comment = "<hr>#{comment}<p><em>&nbsp;&nbsp;--#{author}.....#{Time.now}</em></p>"

    if card.save
      show
    else
      render_errors
    end
  end

  def rollback
    revision = card.revisions[params[:rev].to_i - 1]
    card.update_attributes! :content=>revision.content
    card.attachment_link revision.id
    show
  end


  def watch
    watchers = card.fetch :trait=>:watchers, :new=>{}
    watchers = watchers.refresh
    myname = Card[Account.user_id].name
    watchers.send((params[:toggle]=='on' ? :add_item : :drop_item), myname)
    ajax? ? show(:watch) : read
  end






  #-------- ( ACCOUNT METHODS )

  def update_account

    if params[:save_roles]
      role_card = card.fetch :trait=>:roles, :new=>{}
      role_card.ok! :update

      role_hash = params[:user_roles] || {}
      role_card = role_card.refresh
      role_card.items= role_hash.keys.map &:to_i
    end

    account = card.to_user
    if account and account_args = params[:account]
      unless Account.as_id == card.id and !account_args[:blocked]
        card.fetch(:trait=>:account).ok! :update
      end
      account.update_attributes account_args
    end

    if account && account.errors.any?
      account.errors.each do |field, err|
        card.errors.add field, err
      end
      render_errors
    else
      success
    end
  end

  def create_account
    card.ok!(:create, :new=>{}, :trait=>:account)
    email_args = { :subject => "Your new #{Card.setting :title} account.",   #ENGLISH
                   :message => "Welcome!  You now have an account on #{Card.setting :title}." } #ENGLISH
    @user, @card = User.create_with_card(params[:user], card, email_args)
    raise ActiveRecord::RecordInvalid.new(@user) if !@user.errors.empty?
    #@account = User.new(:email=>@user.email)
#    flash[:notice] ||= "Done.  A password has been sent to that email." #ENGLISH
    params[:attribute] = :account

    wagn_redirect( previous_location )
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
    Account.no_logins? ?
      redirect_to( Card.path_setting '/admin/setup' ) :
      params[:id] = (Card.setting(:home) || 'Home').to_name.url_key
  end


  # FIXME: make me an event
  def load_card
    @card = case params[:id]
      when '*previous'   ; return wagn_redirect( previous_location )
      when /^\~(\d+)$/   ; Card.fetch $1.to_i
      when /^\:(\w+)$/   ; Card.fetch $1.to_sym
      else

        opts = if opts = params[:card]  ; opts.clone
            elsif opts = params[:object]; opts
            else                        {}
            end

        opts[:type] ||= params[:type] # for /new/:type shortcut.  we should fix and deprecate this.
        name = params[:id] || opts[:name]
        
        if @action == 'create'
          # FIXME we currently need a "new" card to catch duplicates (otherwise #save will just act like a normal update)
          # I think we may need to create a "#create" instance method that handles this checking.
          # that would let us get rid of this...
          opts[:name] ||= name
          Card.new opts
        else
          Card.fetch name, :new=>opts
        end
      end

    Wagn::Conf[:main_name] = params[:main] || (card && card.name) || ''
    true
  end

  # FIXME: event
  def refresh_card
    @card = card.refresh
  end


  def success default_target='_self'
    #warn "success #{default_target}, #{card.inspect}"
    target = params[:success] || default_target
    redirect = !ajax?
    new_params = {}

    if Hash === target
      new_params = target
      target = new_params.delete :id # should be some error handling here
      redirect ||= !!(new_params.delete :redirect)
    end

    if target =~ /^REDIRECT:\s*(.+)/
      redirect, target = true, $1
    end

    target = case target
      when '*previous'     ;  previous_location #could do as *previous
      when '_self  '       ;  card #could do as _self
      when /^(http|\/)/    ;  target
      when /^TEXT:\s*(.+)/ ;  $1
      else                 ;  Card.fetch target.to_name.to_absolute(card.cardname), :new=>{}
      end

    case
    when  redirect        ; wagn_redirect ( Card===target ? path_for_page( target.cardname, new_params ) : target )
    when  String===target ; render :text => target
    else
      @card = target
      show new_params[:view]
    end
    true
  end

end

