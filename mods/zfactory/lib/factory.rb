require 'byebug'

module Factory    
  module ClassMethods
    attr_accessor :product_config 
    def factory_process &block
      define_method :engine, &block
    end
    
    def before_factory_process &block
      define_method :before_engine, &block
    end
  
    def store_factory_product args={}, &block
      product_config.merge!(args)
      if block_given?
        define_method :after_engine, &block
      end
    end
  end
  
  def self.included(host_class)
    host_class.extend( ClassMethods )
    host_class.product_config = { :filetype => "txt" }
    
    host_class.card_accessor :product, :type=>:file
    host_class.card_accessor :supplies, :type => :pointer
    
    host_class.before_factory_process {}
    host_class.factory_process { |input| input }
    host_class.format do
      view :product_url do |args|
        product_url
      end
    end
    host_class.store_factory_product do |output|
      store_path =  Wagn.paths['files'].existent.first + "/tmp/#{ id }.#{host_class.product_config[:filetype]}"   
      File.open(store_path,"w") { |f| f.write( output ) }
      Card::Auth.as_bot do
        p = product_card
        p.attach =  File.open(store_path, "r")
        p.save!
      end
    end
    
    # Important: If a card is a supplier and a factory at the same time, this has to happen before the supplier stocktake event
    host_class.event "stocktake_#{host_class.name.gsub(':','_')}".to_sym, :after => :store do  
      stocktake
    end
  end
  
  def manufacture joint=''
    before_engine
    output = supplies_card.item_cards.map do |input|
      if input.respond_to? :deliver
        test = engine( input.deliver ) 
      else
        engine( input.content ) #TODO render_raw instead ?
      end
      "/*#{input.name}*/\n#{test}"
    end.join( "\n" )
    after_engine output
  end
   
  def stocktake updated=[]
    update_supplies_card
    # updated << self
#     supplies_card.item_cards.each do |input|
#       if not updated.include? input and input.respond_to?( :stocktake )
#         updated = input.stocktake(updated) 
#       end
#     end
    manufacture
    return updated
  end
  
  # traverse through all levels of pointers/skins/factories
  # collects all item cards (for pointers/skins) 
  def update_supplies_card
    items = [self] #supplies.present? ? supplies_card.item_cards : self.item_cards
    factory_input = []
    already_extended = [] # avoid loops
    while items.size > 0
      item = items.shift
      if item.trash or already_extended.include? item 
        next
      elsif (new_items = item.item_cards) == [item]  # No pointer card
        factory_input << item
        already_extended << item
      else
        items.insert(0, new_items)
        items.flatten!
        already_extended << item
      end
    end
    
    Card::Auth.as_bot do
      supplies_card.items = factory_input
    end
  end
  
  def product_url
    product_card.attach.url
  end
  
  # def production_number
  #   [current_revision_id.to_s] + supplies_card.item_cards.map do |supplier|
  #     supplier.respond_to?( :production_number ) ? supplier_production_number : supplier.current_revision_id.to_s
  #   end.join('-')
  # end
end


