module Wagn
  class Hook
    class << self
      def reset
        @@registry = {}
      end

      def add hookname, set_name, &block
        @@registry[hookname] ||= {}
        @@registry[hookname][set_name] ||= []
        @@registry[hookname][set_name] << block
      end
    
      def invoke hookname, card_or_set_name, *args
        if !@@registry[hookname] 
          # nothing implementing this hook
          return true 
        end
        set_names = case card_or_set_name
          when Card::Base; Wagn::Pattern.set_names( card_or_set_name )
          when String; [card_or_set_name]
        end
        hooks = set_names.map { |s| @@registry[hookname][s] }.flatten.compact
        hooks.each { |h| h.call(card_or_set_name, *args) }
      end         
    end
  end
end


