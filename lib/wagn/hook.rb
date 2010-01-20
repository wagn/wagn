module Wagn
  class Hook
    cattr_reader :registry
    cattr_accessor :debug
    @@registry = {}
    @@debug = nil #lambda{|x| puts "#{x}<br/>\n" }
  
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
        # FIXME: I'm not sure having the parameter optionally be a card or name
        # is a good idea. it's useful, but I can see it tripping things up when
        # a hook that was defined to expect a card is invoked with a name or vice versa.
        cardname, card = card_or_set_name.is_a?(String) ? 
          [card_or_set_name,nil] : [card_or_set_name.name, card_or_set_name]
        debug.call "#{cardname} :#{hookname}" if debug

        if !@@registry[hookname] 
          # nothing implementing this hook
          return true 
        end

        set_names = case card_or_set_name
          when Card::Base; Wagn::Pattern.set_names( card_or_set_name )
          when String; [card_or_set_name]
        end
        hooks = set_names.map do |s| 
          h=@@registry[hookname][s] 
          debug.call "   - #{s}: #{h.inspect}" if h && debug
          h
        end.flatten.compact
        hooks.each { |h| h.call(card_or_set_name, *args) }
      end         
    end
  end
end

# install Wagn hooks in some of the active record callbacks.
module Card
  class Base
    [:before_save, :before_create, :after_save, :after_create].each do |hookname| 
      self.send( hookname ) do |card|
        Wagn::Hook.invoke hookname, card
      end
    end
  end
end




