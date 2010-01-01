module Wagn
  class Hook
    class << self
      def reset
        @@registry = {}
      end
    end
  end

  class Hook::System < Hook
    @@registry = {}
    class << self
      def register hookname, &block
        list = (@@registry[hookname] ||= [])
        list << block
      end
    
      def invoke hookname, *args
        list = @@registry[hookname] or return true
        list.each do |hook|
          hook.call(*args)
        end
      end
    end
  end

  class Hook::Card < Hook
    @@registry = {}
    class << self
      def register hookname, set_name, &block
        hook_slot = (@@registry[hookname] ||= {})
        hook_pattern_list = (hook_slot[set_name] ||= [])
        hook_pattern_list << block
      end
    
      def invoke hookname, card, *args
        hook_slot = @@registry[hookname] or return true        
        hooks = Wagn::Pattern.set_names( card ).map do |pattern_key|
          hook_slot[pattern_key]
        end.flatten.compact
        hooks.each do |hook|
          hook.call(card, *args)
        end
      end         
    end
  end
end


