module Registerable
  def self.append_features(base)
    base.class_eval %{
      @@registered = {}
      
      def self.registered
        # protect access to hash
        @@registered.dup
      end

      def self.register(id, klass)
        id = id.to_s.strip
        unless @@registered[id]
          @@registered[id] = klass
          klass.class_eval "def self.registered_id; '\#{id}'; end"
        else
          #raise "ID `\#{id}' already registered. Choose another ID."
          warn "ID `\#{id}' already registered. Choose another ID."
        end
      end

      def self.find_all
        self.registered.inject([]) { |a, (k, v)| a << v }.sort_by { |f| f.registered_id }
      end
      
      def self.[](id)
        id = id.to_s.strip
        if @@registered.has_key?(id)
          @@registered[id]
        else
          Base
        end
      end
      
      def self.create(id)
        self[id].new
      end
        
      def self.clear_registry
        @@registered = {}
      end
      
      class Base
        def self.register(id)
          #{base.name}.register(id, self)
        end
        
        def self.registered_id
          nil
        end
        
        def registered_id
          self.class.registered_id
        end
      end
    }
    super
  end
end

require 'active_record'
class ActiveRecord::Base
  def self.registered_attr(symbol, registerable_module)
    module_eval %{
      def #{symbol}
        if @#{symbol}.nil? or (@old_#{symbol}_id != #{symbol}_id)
          @old_#{symbol}_id = #{symbol}_id
          @#{symbol} = #{registerable_module}[#{symbol}_id].new
        else
          @#{symbol}
        end
      end
    }
  end
end