class ConnectionController < ApplicationController
  cache_sweeper :card_sweeper
  helper :card, :wagn
  before_filter :load_card, :edit_ok
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
      # FIXME oh god fixme
      @notice = ""
      @notice << "TAG: #{@tag.errors.full_messages.join(', ')}<br/>\n" unless @tag.errors.empty?
      @notice << "CONNECTION: #{@connection.errors.full_messages.join(', ')}<br/>\n" unless @connection.errors.empty?
      render :action=>'new'
    else
      # switch'm up so @card is the correct one for edit
      @trunk, @card = @card, @connection
      render :action=>'edit'
    end
  end

  def edit      
    @trunk,@tag = @card.trunk,@card.tag #helps with testing
    if updating_type?
      @card.type=params[:card][:type]  
      @card.save!
      @card = Card.find(@card.id)
      @card.content = params[:card][:content]
    end
  end
  
  def update
    if @card.update_attributes params[:card]  
      @context = 'related'
      render :update do |page|
        page.replace_html 'connections-workspace', ''
        page.hide 'empty-card-list'
        page.insert_html :top, 'related-list', :partial=>'card/line', 
          :locals=>{ :card=>@card, :context=>@context, :render_slot=>true }
        page.visual_effect :highlight, slot.id
      end
    else
      render :update do |page|
        page.replace_html slot.id(:notice), :partial=>'/card/trouble'
      end
    end
  end
  
  def remove_tag
    @card = @card.tag 
    remove
  end
  
  def remove
    @card.confirm_destroy = true  
    card_names = ([@card]+@card.dependents).plot(:name).join(' and ')
    if @card.destroy 
      render :update do |page|
        page.replace_html 'connections-workspace', ''
        page.replace_html 'alerts', "#{card_names} removed"
      end
    else
      render :update do |page|
        page.replace_html slot.id(:notice), :partial=>'/card/trouble'
      end
    end
  end
  
  private
    def load_connection
    end
  
end
