module Cardlib::AttributeTracking
  class Updates
    include Enumerable

    def initialize(base)
      @base, @updates, @orig = base, {}, {}
    end

    def add(attribute, new_value)
      @updates[attribute.to_s] = new_value
    end

    def keys
      @updates.keys
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
        attr_names.each { |attr|  @updates.delete(attr.to_s) }
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
      #Rails.logger.debug "tracks(#{fields.inspect})"
      class_eval do
        def updates
          @updates ||= Updates.new(self)
        end
      end

      fields.each do |field|
        unless self.method_defined? field
          dbg='' #dbg = (field == 'name') ? %{Rails.logger.debug "get #{field} "+r.to_s; r;} :  ''
          access = "read_attribute('#{field}')"
          if cache_attribute?(field.to_s)
            access = "@attributes_cache['#{field}'] ||= #{access}"
          end
          #warn "def tracking #{field}; r=(#{access};) #{dbg} end"
          class_eval "def #{field}; r=(#{access};) #{dbg} end"
        end

        unless self.method_defined? "#{field}="
          class_eval code=%{
            def #{field}=(value)
              write_attribute '#{field}', value
            end
          }
          #warn "define= #{code}"
        end

             #Rails.logger.debug "#{field}= "+val.to_s
          #def #{field}_before_type_cast() #{field} end

        class_eval (code = %{
          def #{field}_with_tracking=(val)
             return if (!self.new_record? && self.#{field} == val)
             updates.add :#{field}, val
          end
          alias_method_chain :#{field}=, :tracking

          def #{field}_with_tracking
            r=updates.for?(:#{field}) ? updates.for(:#{field}) : #{field}_without_tracking
          end
          alias_method_chain :#{field}, :tracking
        })
            #Rails.logger.debug('#{field} is ' + r.to_s); r
        #warn code
      end

    end
  end

  def self.included(base)
    super
    base.extend(ClassMethods)
  end
end
