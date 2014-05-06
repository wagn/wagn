require 'byebug'

module Factory    
  module ClassMethods
    attr_accessor :output_config, :before_engine, :engine, :after_engine
    def factory_process &block
      #self.engine = block
      define_method :engine, &block
    end
    
    def before_factory_process &block
      define_method :before_engine, &block
    end
  
    def store_factory_output *args, &block
      if block_given?
        define_method :after_engine, &block
        #self.after_engine = block
      else
        define_method :after_engine do
          #TODO do something with args
        end
        
      end
    end
  
    def arount_factory_process &block   #TODO - not used, I doubt that this will work. factory_input_cards is a instance method!
      block.call( Proc.new do 
                    factory_input_cards.each { |input| @engine.call( input ) }
                  end     
                )
    end
  end
  
  
  def self.included(host_class)
    host_class.extend( ClassMethods )
    host_class.output_config = { :filetype => "txt" }
    
    host_class.before_factory_process {}
    host_class.factory_process { |input| input }
    
    host_class.store_factory_output do |output|
      store_path =  Wagn.paths['files'].existent.first + "/tmp/#{ id }.#{host_class.output_config[:filetype]}"   
      file = File.open(store_path,"w")
      file.write( output )
      Card::Auth.as_bot do
        output_card.attach = file
        output_card.save!
      end
    end
    
    host_class.event "stocktake_#{host_class.class.name}", :after => :store do 
      stocktake
    end
  end
  
  
  def factory_input_cards
    input_pointer = Card.fetch "#{name}+*input"
    items = input_pointer.present? ? input_pointer.item_cards : self.item_cards
    input = []
    while items.size > 0
      if items.first.type_id == Card::PointerID
        items[0] = items[0].item_cards
        items.flatten!
      else
        item = items.shift  
        input +=  item.respond_to?( :factory_input_cards ) ? item.factory_input_cards : item.item_cards
      end
    end
    input.flatten
  end
  
  
  def update_input
    Card::Auth.as_bot do
      c = Card.fetch "#{name}+*input", :new => {:type => Card::PointerID}
      c.content = ''
      factory_input_cards.each do |item|
        c << item
      end
      c.save!
    end
  end
  
  def output_card
    Card.fetch "#{name}+*output", :new => {:type => Card::FileID}
  end
  
  def factory_output # maybe this should be a view
    output_card
  end
  
  def deliver
    output
  end
  
 

  
  def manufacture joint=''
    before_engine
    output = factory_input_cards.map do |input|
      engine( input ) 
    end.join( joint )
    after_engine output
    # before_factory_process
#     output = factory_input_cards.map do |input|
#       factory_process( input ) 
#     end.join( joint )
#     store_factory_product output
    # if self.class.before_engine.respond_to? :call
    #   self.class.before_engine.call
    # end
    # if self.class.engine.is_block?
    #   output = factory_input_cards.map do |input|
    #     self.class.engine.call( input ) 
    #   end.join( joint )
    #   if self.class.engine.respond_to? :call
    #     self.class.after_engine.call(output)
    #   end
    # else
    #   raise Exception, "No factory engine given. Use factory_process to define on."
    # end
  end
  
  def before_factory_process
  end
  
  def factory_process input
    input
  end
  
  def store_product output
    store_path =  Wagn.paths['files'].existent.first + "/tmp/#{ id }.#{host_class.output_config[:filetype]}"   
    file = File.open(store_path,"w")
    file.write( output )
    Card::Auth.as_bot do
      output_card.attach = file
      output_card.save!
    end
  end
   
  def stocktake updated=[]
    update_input
    updated << self
    factory_input_cards.each do |input|
      if not updated.include? input and input.responds_to?( :stocktake )
        updated = input.stocktake(updated) 
      end
    end
    manufacture
    return updated
  end
  
  def production_number
    [current_revision_id.to_s] + factory_input_cards.map do |supplier|
      supplier.respond_to?( :production_number ) ? supplier_production_number : supplier.current_revision_id.to_s
    end.join('-')
  end
end



### Example use-cases
## Factory comes with
# +*input
# +*ouput

# module Card::Set::Type::Skin
#   include Factory
#     
#   around_production do  # too complicated? just redefine manufacture?
#     @assemble = {}
#     [:js, :css].each do |type|
#       @assemble[:type] = { :filename => "#{key}-#{production_number}.#{type}", :content => '' }
#     end
#     @assemble[:css][:input_type] =  [Card::CssID, Card::ScssID]
#     @assemble[:js][:input_type] =  [Card::JavascriptID, Card::CoffeeScriptID]
#     
#     yield
#     
#     @assemble.each do |type|
#       File.open type[:filename], 'w' do |f|
#         f.write type[:content]
#       end
#     end
#   end
#   
#   process_input do |input|
#     @assemble.each do |type|
#       if type[:input_type].include? input.type_id
#         type[:content] += input.responds_to?( :deliver ) ? input.deliver : input.content   
#         break
#       end
#     end
#   end
#   
#   prepare_production do
#   end
#     
#   store_product do |output|
#   end
#   
#   
#   def output # view maybe?
#     %{
#       <link href="/files/#{filename}.css" media="all" rel="stylesheet" type="text/css">
#       <script  >
#     }
#   end
# end
# 
# 
# module Card::Set::Type::Css
#   include Supplier
#   
#   event
#   
#   #supply_for :type => 'Skin'
#   supply_restricted_to :type => 'Skin'
#   deliver :view => :core
#   
#   process_input do |input|
#   end
#   
#   # create content in view or save in +*output ? 
#   view :core do |args|
#     # FIXME: scan must happen before process for inclusion interactions to work, but this will likely cause
#     # problems with including other css?
#     process_content ::CodeRay.scan( _render_raw, :css ).div, :size=>:icon
#   end
#   
# end

