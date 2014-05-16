module Machine    
  module ClassMethods
    attr_accessor :output_config 
    
    def machine_engine &block
      define_method :engine, &block
    end
    
    def prepare_machine_input &block
      define_method :before_engine, &block
    end
  
    def store_machine_output args={}, &block
      output_config.merge!(args)
      if block_given?
        define_method :after_engine, &block
      end
    end
  end
  
  def self.included(host_class)
    host_class.extend( ClassMethods )
    host_class.output_config = { :filetype => "txt" }
    
    host_class.card_accessor :machine_output, :type=>:file
    host_class.card_accessor :machine_input, :type => :pointer
    
    # default engine
    host_class.prepare_machine_input {}
    host_class.machine_engine { |input| input }
    host_class.store_machine_output do |output|
      store_path =  Wagn.paths['files'].existent.first + "/tmp/#{ id }.#{host_class.output_config[:filetype]}"   
      File.open(store_path,"w") { |f| f.write( output ) }
      Card::Auth.as_bot do
        p = machine_output_card
        p.attach =  File.open(store_path, "r")
        p.save!
      end
    end
    
    host_class.format do
      view :machine_output_url do |args|
        machine_output_url
      end
    end
    
    # Important: If a card is machine and machine input at the same time, this has to happen before the machine input update event
    host_class.event "update_machine_output_#{host_class.name.gsub(':','_')}".to_sym, :after => :store, :on => :save do  
      update_machine_output
    end
  end
  
  def run_machine joint=''
    before_engine
    output = input_item_cards.map do |input|
      if input.respond_to? :machine_input
        engine( input.machine_input ) 
      else
        engine( input.format._render_raw )
      end
    end.join( joint )
    after_engine output
  end
   
  def update_machine_output updated=[]
    update_input_card
    run_machine
  end
  
  
  # traverse through all levels of pointers/skins/factories
  # collects all item cards (for pointers/skins) 
  def update_input_card
    items = [self]
    new_input = []
    already_extended = [] # avoid loops
    while items.size > 0
      item = items.shift
      if item.trash or already_extended.include? item 
        next
      elsif item.item_cards == [item]  # No pointer card
        new_input << item
        already_extended << item
      else
        items.insert(0, item.item_cards)
        items.flatten!
        already_extended << item
      end
    end
    
    Card::Auth.as_bot do
      machine_input_card.items = new_input
    end
  end
  
  def input_item_cards
    machine_input_card.item_cards
  end
  
  def machine_output_url
    machine_output_card.attach.url
  end 
  
  def machine_output_path
    machine_output_card.attach.path
  end 
end


