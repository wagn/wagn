module Factory
  def asdfsa
  end
  
  def self.include(host_class)
    host_class.after_engine = Proc.new do
      Account.as_bot do
        output_card.content = output
        output_card.save!
      end
    end
    host_class.before_engine = Proc.new {}
    host_class.engine = Proc.new {|input| input }
  end
  
  def input_cards
    input_pointer = Card.fetch "#{item.name}+*input"
    items = input_pointer.present? ? input_pointer.item_cards : self.item_cards
    input = []
    while items.size > 0
      item = items.pop  
      if item.type_id == Card::PointerID
        items += item.item_cards
      else
        input +=  item.respond_to?( :input_cards ) ? item.input_cards : item.item_cards
      end
    end
    input.flatten
  end
  
  
  def update_input
    c = Card.fetch "#{item.name}+*input", :new => {:type => Card::PointerID}
    Account.as_bot do
      c.content = ''
      input_cards.each do |item|
        c << item
      end
      c.safe!
    end
  end
  
  def output_card
    Card.fetch "#{name}+*output", :new => {:type => Card::PlainTextID}
  end
  
  def output # maybe this should be a view
    output_card.content
  end
  
  def deliver
    output
  end
  
  def self.prepare_production &block
    before_engine = block
  end
  
  def self.process_input &block
    engine = block
  end
  
  def self.store_product &block
    after_engine = block
  end
  
  def arount_production &block
    block.call( Proc.new do 
                  input_cards.each { |input| @machine.call( input ) }
                end     
              )
  end
  
  def manufacture joint=''
    @before_machine.call if @before_machine.is_block?
    if @machine.is_block?
      output = input_cards.map do |input|
        @machine.call( input ) 
      end
      @after_machine.call(output) if @after_machine.is_block?
    else
      raise Exception, "No machine given. Use process_input to define on."
    end
  end
  

  def prepare_production
  end
  
  def store_product output
    Account.as_bot do
      output_card.content = output
      output_card.save!
    end
  end
   
  def stocktake
    update_input
    input_cards.each do |input|
      input.stocktake if input.responds_to?( :stocktake )
    end
    manufacture
  end
  
  def production_number
    [current_revision_id.to_s] + input_cards.map do |supplier|
      supplier.respond_to?( :production_number ) ? supplier_production_number : supplier.current_revision_id.to_s
    end.join('-')
  end
end


module Supplier
  def self.included host_class
    host_class.search_args = {}
    host_class.event "stocktake_#{host_class.class.name}".to_sym, :after=>:store do
      recipients = Card.search( {:right_plus => [{:codename => "input"}, {:link_to => name} ]}.merge(host_class.search_args) )   #TODO - correct query, somehting like { "plus": ["*input","link_to":"_self"]}
      recipients.each do |item|
        item.stocktake if item.kind_of? Factory
      end
    end
  end
  
  def self.supply_for args
    self.search_args = args
  end
  
  def self.deliver args
    deliver_options = args
  end
  
  def deliver
    #TODO 
  end
  
  def production_number
    current_revision_id.to_s
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

