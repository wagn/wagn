# -*- encoding : utf-8 -*-
class CardController < ApplicationController

  helper :wagn

  before_filter :load_id, :only => [ :read ]
  before_filter :load_card
  before_filter :refresh_card, :only=> [ :create, :update, :delete, :rollback ]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
  #  CORE METHODS
  
  def create
    handle { card.save }
  end

  def read
    save_location # should be an event!
    show
  end

  def update
    card.new_card? ? create : handle { card.update_attributes params[:card] }
  end

  def delete
    discard_locations_for card #should be an event
    params[:success] ||= 'REDIRECT: *previous'
    handle { card.delete }
  end

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## the following methods need to be merged into #update

  def save_draft
    if card.save_draft params[:card][:content]
      render :nothing=>true
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
    myname = Account.current.name
    watchers.send((params[:toggle]=='on' ? :add_item : :drop_item), myname)
    watchers.save!
    ajax? ? show(:watch) : read
  end



  #-------- ( ACCOUNT METHODS )

  def update_account
    if params[:save_roles]
      role_card = card.fetch :trait=>:roles, :new=>{}
      role_card.ok! :update

      role_hash = params[:account_roles] || {}
      role_card = role_card.refresh
      role_card.items= role_hash.keys.map &:to_i
    end

    acct = card.account
    if acct and account_args = params[:account]
      account_args[:blocked] = account_args[:blocked] == '1'
      if Account.as_id == card.id
        raise Wagn::Oops, "can't block own account" if account_args[:blocked]
      else
        card.fetch(:trait=>:account).ok! :update
      end
      acct.update_attributes account_args
      acct.errors.each do |key,err|
        card.errors.add key,err
      end
    end

    handle { card.errors.empty? }
  end

  def create_account
    raise Wagn::PermissionDenied, "can't add account to this card" unless card.accountable?
    email_args = { :subject => "Your new #{Card.setting :title} account.",   #ENGLISH
                   :message => "Welcome!  You now have an account on #{Card.setting :title}." } #ENGLISH
    @account, @card = Account.create_with_card params[:account], card, email_args
    
    handle { card.errors.empty? }
  end



  private
  
  def handle
    yield ? success : render_errors
  end
  
  #-------( FILTERS )

  def refresh_card
    @card =  card.refresh
  end

  def load_id    
    params[:id] = case
      when params[:id]
        params[:id].gsub '_', ' '
        # with unknown cards, underscores in urls assumed to indicate spaces.
        # with known cards, the key look makes this irrelevant
        # (note that this is not performed on params[:card][:name])          
      when Account.no_logins?
        return wagn_redirect( '/admin/setup' )
      when params[:card] && params[:card][:name]
        params[:card][:name]
      when Card::Format.tagged( params[:view], :unknown_ok )
        ''
      else  
        Card.setting(:home) || 'Home'
      end
  rescue ArgumentError # less than perfect way to handle encoding issues.
    raise Wagn::BadAddress
  end
  

  def load_card
    @card = case params[:id]
      when '*previous'
        return wagn_redirect( previous_location )
      when /^\~(\d+)$/
        Card.fetch( $1.to_i ) or raise Wagn::NotFound 
      when /^\:(\w+)$/
        Card.fetch $1.to_sym
      else
        opts = params[:card]
        opts = opts ? opts.clone : {} #clone so that original params remain unaltered.  need deeper clone?
        opts[:type] ||= params[:type] # for /new/:type shortcut.  we should fix and deprecate this.
        name = params[:id] || opts[:name]
        
        if params[:action] == 'create'
          # FIXME we currently need a "new" card to catch duplicates (otherwise #save will just act like a normal update)
          # I think we may need to create a "#create" instance method that handles this checking.
          # that would let us get rid of this...
          opts[:name] ||= name
          Card.new opts
        else
          Card.fetch name, :new=>opts
        end
      end
    @card.selected_revision_id = params[:rev].to_i if params[:rev]

    Wagn::Conf[:main_name] = params[:main] || (card && card.name) || ''
    render_errors if card.errors.any?
    true
  end



  #------- REDIRECTION 

  def success
    redirect, new_params = !ajax?, {}
    
    target = case params[:success]
      when Hash
        new_params = params[:success]
        redirect ||= !!(new_params.delete :redirect)
        new_params.delete :id
      when /^REDIRECT:\s*(.+)/
        redirect=true
        $1
      when nil  ;  '_self'
      else      ;   params[:success]
      end
        
    target = case target
      when '*previous'     ;  previous_location #could do as *previous
      when '_self  '       ;  card #could do as _self
      when /^(http|\/)/    ;  target
      when /^TEXT:\s*(.+)/ ;  $1
      else                 ;  Card.fetch target.to_name.to_absolute(card.cardname), :new=>{}
      end

    case
    when redirect
      target = page_path target.cardname, new_params if Card === target
      wagn_redirect target
    when String===target
      render :text => target
    else
      @card = target
      self.params = self.params.merge new_params #need tests.  insure we get slot, main...
      show
    end
  end

end

