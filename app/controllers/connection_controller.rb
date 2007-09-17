class ConnectionController < ApplicationController
  cache_sweeper :card_sweeper
  helper :card, :wagn
  before_filter :load_card
  layout :ajax_or_not
  
  def create
    # id will be for the trunk (card we're connecting to)
    # @name 
    if @tag = Card.find_by_name(params[:name])
    else
      @new_tag = true
      @tag = Card.create :name=>params[:name]
    end
    @connection = Card::Basic.create :trunk=>@card, :tag=>@tag
                                      
    if !@tag.errors.empty? or !@connection.errors.empty?
      # FIXME oh god fix me please
      @notice = ""
      @notice << "JOINEE: #{@tag.errors.full_messages.join(', ')}<br/>\n" unless @tag.errors.empty?
      @notice << "JUNCTION: #{@connection.errors.full_messages.join(', ')}<br/>\n" unless @connection.errors.empty?
      render :action=>'new'
    else
      # switch'm up so @card is the correct one for edit
      @trunk, @card = @card, @connection
      render :action=>'edit'
    end
  end

  def edit      
    @trunk,@tag = @card.trunk,@card.tag #helps with testing
    @card = handle_cardtype_update(@card)
  end
  
  def update
    @card.update_attributes! params[:card]  
    # FIXME: !!!this is only gonna work the first time
    @context = 'related:0'
    render :update do |page|
      page.replace_html 'connections-workspace', ''
      page.hide 'empty-card-list'
      page.insert_html :top, 'related-list', :partial=>'card/line', 
        :locals=>{ :card=>@card, :context=>@context, :render_slot=>true }
      page.visual_effect :highlight, slot.id
    end
  end
  
  def remove_tag
    @card = @card.tag 
    remove
  end
  
  def remove
    @card.confirm_destroy = true  
    card_names = ([@card]+@card.dependents).plot(:name).join(' and ')
    @card.destroy!     
    render :update do |page|
      page.replace_html 'connections-workspace', ''
      page.replace_html 'alerts', "#{card_names} removed"
    end
  end
  
  def new
    @likely = load_cards :card=>@card,:query=>'common_tags'
    @already = load_cards :card=>@card, :query=>'plussed_cards'
    @already_ids = @already.plot :id
    @likely.reject! {|c| @already_ids.member? c.id }
  end
  
  private
    def load_connection
    end
  
end
