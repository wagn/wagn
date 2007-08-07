module ActiveRecord
  module AttributeTracking
    class Updates
      include Enumerable
      
      def initialize(base)
        @base, @updates, @orig = base, {}, {}
      end
      
      def add(attribute, new_value)
        @updates[attribute.to_s] = new_value
      end
                   
      def each
        @updates.each { |attr| yield attr }        
      end
      
      def each_pair
        @updates.each_pair { |attr,value| yield attr, value }        
      end
      
      def clear(*attr_names)
        if attr_names.empty?
          @updates = {}
        else
          attr_names.each do |attr|
            @updates.delete(attr.to_s)
          end
        end
      end

      def for?(attr)
        @updates.has_key?(attr.to_s)
      end
       
      def for(attr)
        @updates[attr.to_s]
      end
      alias :[] :for
    end
    
    module ClassMethods 
      # Important! Tracking should be declared *after* associations
      def tracks(*fields)
        class_eval do
          def updates
            @updates ||= Updates.new(self)
          end
        end

        fields.each do |field|   
          unless self.method_defined? field
            #warn "defining #{field}"
            class_eval %{
              def #{field}
                read_attribute '#{field}'
              end
            }
          end
          
          unless self.method_defined? "#{field}="
            #warn "defining #{field}="
            class_eval %{
              def #{field}=(value)
                write_attribute '#{field}', value
              end
            }
          end

          class_eval %{
            def #{field}_with_tracking=(val)
               updates.add :#{field}, val
            end
            alias_method_chain :#{field}=, :tracking

            def #{field}_before_type_cast
              #{field}
            end
            
            def #{field}_with_tracking
              updates.for?(:#{field}) ? updates.for(:#{field}) : #{field}_without_tracking
            end
            alias_method_chain :#{field}, :tracking
          }
        end
        
      end
    end
    
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::AttributeTracking
end
