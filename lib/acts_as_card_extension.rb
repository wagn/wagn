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
          class_eval do
            def cardname
              if card 
                card.name
              else 
                name = respond_to?(:codename) ? codename : "#{self.class} #{self.id}"
              #  warn "#{name} should have had a card!"
                name
              end
            end

          end

        end
      end
      
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::CardExtension
end
