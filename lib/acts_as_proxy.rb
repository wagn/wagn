module ActiveRecord
  module Acts
    module Proxy
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_proxy(association, *attributes)
          options = attributes.last.is_a?(Hash) ? attributes.pop : {}
          config = {  :auto_create => true, :setters => {} }.update(options)
          
          class_eval <<-EOV
            def build_#{association}_with_proxy_attributes( options = {} )
              @#{association}_attributes ||= {}
              proxy_options = options.merge(@#{association}_attributes)
              build_#{association}( proxy_options )
            end
            
            if config[:auto_create]
              before_validation_on_create :build_#{association}_with_proxy_attributes
            end
            
          EOV
           
          attributes.each do |attr| 
            setter = config[:setters].has_key?(attr) ? config[:setters][attr] : "#{attr}="
            class_eval <<-EOV
              def #{attr}
                @#{association}_attributes ||= {}
                #{association} ? #{association}.#{attr} : @#{association}_attributes['#{attr}']
              end
              
              def #{attr}=(value)
                @#{association}_attributes ||= {}
                #warn '@#{association}_attributes' + @#{association}_attributes.to_s
                #{association} ? #{setter}(value) : @#{association}_attributes['#{attr}'] = value
              end
            EOV
          end
          
        end
      end
      
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::Proxy
end
