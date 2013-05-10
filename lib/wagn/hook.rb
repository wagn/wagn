# -*- encoding : utf-8 -*-
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

      def call hookname, card_or_set_name, *args
        return [] unless @@registry[hookname]

        if card_or_set_name.is_a?(String)
          call_set_name hookname, card_or_set_name, *args
        else
          call_card hookname, card_or_set_name, *args
        end
      end

      def call_card hookname, card, *args
        hooks_for_set_names(hookname, card.set_names).map do |h|
          h.call(card, *args)
        end
      end

      def call_set_name hookname, set_name, *args
        hooks_for_set_names(hookname,[set_name]).map do |h|
          h.call(set_name, *args)
        end
      end

      def hooks_for_set_names hookname, set_names
        set_names.map do |s|
          h=@@registry[hookname][s]
          debug.call "   - #{s}: #{h.inspect}" if h && debug
          h
        end.flatten.compact
      end
    end
  end
end




