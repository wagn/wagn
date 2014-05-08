module Supplier
  module ClassMethods
    attr_accessor :recipients, :deliver_config
    
    def supply_for args
      @recipients = args
    end
    
    def deliver &block
      define_method :deliver, block
    end
  end
  
  def self.included host_class
    host_class.extend( ClassMethods )
    host_class.recipients = {}
    host_class.deliver do
      content
    end
    host_class.event "stocktake_#{host_class.class.name}".to_sym, :after=>:store_subcards do
      recipients = Card.search( {:right_plus => [{:codename => "supplies"}, {:link_to => name}]}.merge(host_class.recipients) )  #TODO - correct query, somehting like { "plus": ["*input","link_to":"_self"]}
      recipients.each do |item|
        item.stocktake if item.kind_of? Factory
      end
    end
  end
    
  def production_number
    current_revision_id.to_s
  end
end

