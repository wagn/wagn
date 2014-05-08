require 'byebug'

module Factory    
  module ClassMethods
    attr_accessor :product_config #, :before_engine, :engine, :after_engine
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
        #self.after_engine = block
      end
      # else
#         define_method :after_engine do
#           #TODO do something with args
#         end
#       end
    end
  
    # def around_factory_process &block   #TODO - not used, I doubt that this will work. factory_input_cards is a instance method!
#       block.call( Proc.new do 
#                     factory_input_cards.each { |input| engine( input ) }
#                   end     
#                 )
#     end
  end
  
   
  
  
  def self.included(host_class)
    host_class.extend( ClassMethods )
    host_class.product_config = { :filetype => "txt" }
    
    host_class.card_accessor :product, :type=>:file
    host_class.card_accessor :supplies, :type => :pointer
    
    host_class.before_factory_process {}
    host_class.factory_process { |input| input }
    host_class.store_factory_product do |output|
      store_path =  Wagn.paths['files'].existent.first + "/tmp/#{ id }.#{host_class.product_config[:filetype]}"   
      File.open(store_path,"w") { |f| f.write( output ) }
      Card::Auth.as_bot do
        p = product_card
        p.attach =  File.open(store_path, "r")
        p.save!
      end
    end
    
    host_class.event "stocktake_#{host_class.name.gsub(':','_')}".to_sym, :after => :store_subcards do 
      stocktake
    end
  end
  
  def manufacture joint=''
    before_engine
    output = supplies_card.item_cards.map do |input|
      if input.respond_to? :deliver
        engine( input.deliver ) 
      else
        engine( input.content ) #TODO render_raw instead ?
      end
    end.join( joint )
    after_engine output
  end
   
  def stocktake updated=[]
    update_supplies_card
    updated << self
    supplies_card.item_cards.each do |input|
      if not updated.include? input and input.respond_to?( :stocktake )
        updated = input.stocktake(updated) 
      end
    end
    manufacture
    return updated
  end
  
  # traverse through all levels of pointers/skins/factories
  # collects all item cards (for pointers/skins) and input cards (for factories)
  # use [self] if this card has no input items
  def update_supplies_card
    items = supplies.present? ? supplies_card.item_cards : self.item_cards
    factory_input = []
    while items.size > 0
      if items.first.type_id == Card::PointerID
        items[0] = items[0].item_cards
        items.flatten!
      else
        item = items.shift  
        if item == self
          factory_input << item
        else
          factory_input +=  item.respond_to?( :supplies_card ) ? item.supplies_card.item_cards : item.item_cards
        end
      end
    end
    
    Card::Auth.as_bot do
      supplies_card.items = factory_input
    end
  end
  
  # def product_card
 #    Card.fetch "#{name}+product", :new => {:type => :file}
 #    #fetch :trait => :product #, :new => {:type => :file}
 #  end
  
  # def supplies_card
  #   #Card.fetch "#{name}+supplies", :new => {:type => :pointer}
  #   self.fetch :trait => :supplies#, :new => {:type => :pointer}
  # end
  # 
  # def supplies
  #   supplies_card.content if supplies_card
  # end
  
  def production_number
    [current_revision_id.to_s] + supplies_card.item_cards.map do |supplier|
      supplier.respond_to?( :production_number ) ? supplier_production_number : supplier.current_revision_id.to_s
    end.join('-')
  end
  
end

