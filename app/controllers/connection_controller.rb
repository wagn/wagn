class ConnectionController < ApplicationController
  cache_sweeper :card_sweeper
  helper :card, :wagn
  before_filter :load_card
  layout :ajax_or_not
  
  def new
    if params[:card] and params[:card][:name]
      @trunk = @card
      @tag = Card.find_or_new params[:card]
      @connection = Card::Basic.new :trunk=>@trunk, :tag=>@tag
      @connection.send(:set_defaults)
    else
      render :action=>'tag_cloud'
    end
  end

=begin  
  def create_form
    # this is a terrible hack to force format==html in case we throw an oops.
    # even though the Ajax is an update, it comes out requesting js otherwise
    request.env['HTTP_ACCEPT']='text/html'  
    
    @trunk = Card.find_by_id params[:id] 
    @tag = Card.find_or_new params[:card]
    @connection = Card::Basic.new :trunk=>@trunk, :tag=>@tag
    @connection.send(:set_defaults)
  end
=end
  
  def create
    @trunk = Card.find_by_id(params[:id])
    @tag  = Card.find_or_create params[:card]
    @connection = Card.create! params[:connection].merge(:trunk=>@trunk, :tag=>@tag)
    if params[:personal_sidebar]
      @connection.reader = User.current_user #fixme-perm  -- not how we should do this.
      @connection.save!
      Card::Basic.create! :trunk=>@connection, :tag=>Card.find_by_name('*sidebar')
    end
  end
  
  def remove
    @connection = Card.find_by_id(params[:id])
    @trunk = @connection.trunk
    @tag = @connection.tag
    @connection.destroy!
    # FIXME if we somehow flagged that the tag_card was created specifically for this connection,
    # we could remove it here
  end
  
  private
    def load_connection
    end
  
end
