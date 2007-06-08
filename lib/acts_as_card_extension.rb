module ActiveRecord
  module Acts
    module CardExtension
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_card_extension( options = {})
          has_one :card, :as=>:extension
          
          #acts_as_proxy :card, 'name'
          
          class_eval <<-EOV
          EOV
        end
      end
      
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::CardExtension
end
