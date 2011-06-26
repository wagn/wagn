module Wagn::Card::AttributeTracking
  class Updates
    include Enumerable
    
    def initialize(base)
      @base, @updates, @orig = base, {}, {}
    end
    
    def add(attribute, new_value) 
      #warn "ADD #{attribute} #{new_value}" 
      attribute=attribute.to_s
      if attribute=="content" && new_value=="balogna"
        if @woop==1
          raise("WOAH THERE CPWBODY")
        else 
          @woop ||= 1
        end
      end
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
          #warn "DELETNG: #{attr}"
          @updates.delete(attr.to_s)
          #warn "ATTRS AFTER DEL: #{self.for(:typecode)}"
        end
      end
    end

    def for?(attr)
      #puts "ATTRS AT CHECK #{attr}: #{@updates.inspect}"
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
      #Rails.logger.debug "tracks(#{fields.inspect})"
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
              v=read_attribute '#{field}'
            end
          }
        end
        #Rails.logger.warn ">#{field}: "+(v ? v.to_s : ''); v
        
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
             return if (!self.new_record? && self.#{field} == val)
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
  
  def self.included(base)
    super
    base.extend(ClassMethods)
  end
end
