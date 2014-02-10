# -*- encoding : utf-8 -*-
class CardController < WagnController

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




  private
  
  
  #-------( FILTERS )

  def refresh_card
    @card =  card.refresh
  end

  def load_id    
    params[:id] = case
      when params[:id]
        params[:id]
      when Account.no_logins?
        return wagn_redirect( 'admin/setup' )
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

    Wagn::Env[:main_name] = params[:main] || (card && card.name) || ''
    render_errors if card.errors.any?
    true
  end


end

