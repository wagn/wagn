module Supplier
  def self.included host_class
    host_class.search_args = {}
    host_class.event "stocktake_#{host_class.class.name}".to_sym, :after=>:store do
      (recipients = Card.search {:right_plus => [:codename => "input", :link_to => name]}.merge(search_args) )  #TODO - correct query, somehting like { "plus": ["*input","link_to":"_self"]}
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