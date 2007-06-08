class ConnectionController < ApplicationController
  #before_filter :login_required, :except => [ :main, :view, :connections ]
  observer :card_observer, :tag_observer
  cache_sweeper :card_sweeper
  helper :card, :wagn
  
  #before_filter :load_connection, :except=>[:new, :create ]
  layout :ajax_or_not
  
  def new
    @trunk = Card.find_by_id(params[:id]) 
    @tag   = Tag.new
  end
  
  def create_form
    # this is a terrible hack to force format==html in case we throw an oops.
    # even though the Ajax is an update, it comes out requiesting js otherwise
    request.env['HTTP_ACCEPT']='text/html'  
    
    @trunk = Card.find_by_id(params[:id])  
    params[:tag][:name].strip!
    if @tag_card = Card.find_by_name(params[:tag][:name])
      @tag = @tag_card.tag
    else 
      @tag = Tag.new( { 'datatype_key'=>'RichText', 'plus_datatype_key'=>'RichText' }.merge(params[:tag]))
      tag_revision = TagRevision.new :name=>params[:tag][:name]
      @tag_card = Card::Basic.new(:tag=>@tag, :name=>@tag.name, :content=> "")
      @tag.root_card = @tag_card
      if !tag_revision.valid?
        raise ActiveRecord::RecordInvalid.new(tag_revision)
      end
    end
    @connection = @trunk.connect! @tag_card, '', dry_run=true
  end
  
  def create
    @trunk = Card.find_by_id(params[:id])
    params[:tag][:name].strip!
    if @tag_card = Card.find_by_name(params[:tag][:name]) 
    else 
      @tag_card = Card::Basic.create!(:name=>params[:tag][:name], :content=> "")
    end
    @connection = @trunk.connect! @tag_card, params[:connection][:content], dry_run=true
    if params[:personal_sidebar]
      @connection.reader = User.current_user
      @connection.save!
      @connection.connect!( Card.find_by_name('*sidebar') )
    else
      @connection.save!
    end
  end
  
  def remove
    @connection = Card.find_by_id(params[:id])
    @trunk = @connection.trunk
    @tag_card = @connection.tag.root_card
    @connection.destroy
    # FIXME if we somehow flagged that the tag_card was created specifically for this connection,
    # we could remove it here
  end
  
  private
    def load_connection
    end
  
end
