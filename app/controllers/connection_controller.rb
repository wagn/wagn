class ConnectionController < ApplicationController
  cache_sweeper :card_sweeper
  helper :card, :wagn
  before_filter :load_card
  layout :default_layout
  
  def create
    # id will be for the trunk (card we're connecting to)
    # @name 
    if @tag = Card.find_by_name(params[:name]||'')
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
      #self.new()
                           
      load_likely
      render :action=>'new'
    else
      # switch'm up so @card is the correct one for edit
      render :action=>'review'
    end
  end
  
  def edit  
    @card = handle_cardtype_update(@card)    
  end

  def new
    load_likely
  end
  
  def remove
    @card.confirm_destroy = true  
    card_names = ([@card]+@card.dependents).plot(:name).join(' and ')
    @card.destroy! 
    return_to_related
  end

  def remove_tag
    @card = @card.tag 
    remove
  end

  def review
    name = params[:name]
    @tag = Card.find_by_name(name) || raise(Wagn::Oops, "card named #{name} doesn't exist!")
    @connection = Card.find_by_name("#{@card.name}+#{name}") || Card.find_by_name("#{name}+#{@card.name}")
  end
    
  def update
    @card.update_attributes! params[:card]
    return_to_related
  end

  
  private
  def load_connection
  end
  
  def load_likely       
    @likely = Card.search( :group_tagging=>@card.type )
    @already = Card.search(:plus=>'_self', :_card=>@card )
    @already_ids = @already.plot :id
    @likely.reject! {|c| @already_ids.member? c.id }
  end  

  # FUN!  the connection-edit slot is inside the connection-review slot,
  #  so after update & remove we have to resort to some funk to make it 
  # update the parent slot with the right card
  def return_to_related
    @card = @card.trunk
    related_screen = render_to_string( :template=>'/card/related')
    render :update do |page|
      page.extend(WagnHelper::MyCrappyJavascriptHack) 
      page.select_slot(%{getSlotSpan(getSlotFromContext('#{@context}').parentNode)}).each() do |target,index|
        target.update(related_screen)
      end
    end
  end

  def handle_cardtype_update(card)
    #FIXME -- only one call.  phase out?
    if updating_type?  
      #old_type = card.type
      card.type=params[:card][:type]  
      card.save!
      card = Card.find(card.id)
      content = params[:card][:content]
      content = strip_tags(content) unless (card.class.superclass.to_s=='Card::Basic' or card.type=='Basic')
      card.content = content
    end
    card
  end
  
  def updating_type?
    request.post? and params[:card] and params[:card][:type]
  end

end
