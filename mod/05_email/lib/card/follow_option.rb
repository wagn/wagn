# -*- encoding : utf-8 -*-


class Card
  module FollowOption
    attr_reader :exclusive
    mattr_reader :codenames, :special
    @@codenames = []
    @@special = []

    
    def self.included(host_class)     
       host_class.extend ClassMethods
    end
    
    def exclusive
      false
    end
    
    def description set_card
      set_card.follow_label
    end

    module ClassMethods
      #mattr_reader :names
      
      
      # usage:
      # follow_opts :position => <Fixnum> (starting at 1, default: add to end)
      def follow_opts opts
        codename = opts[:codename] || self.name.match(/::(\w+)$/)[1].underscore.to_sym
        if opts[:special]
          Card::FollowOption.special << codename
        end
        if opts[:position]
          if Card::FollowOption.codenames[opts[:position]-1]
            Card::FollowOption.codenames.insert(opts[:position]-1, codename)
          else
            Card::FollowOption.codenames[opts[:position]-1] = codename
          end
        else
          Card::FollowOption.codenames << codename
        end
      end
    end   
  end
end
