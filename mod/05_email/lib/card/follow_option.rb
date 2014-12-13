# -*- encoding : utf-8 -*-


class Card
  module FollowOption
    mattr_reader :names
    @@names = []

    
    def self.included(host_class)     
       host_class.extend ClassMethods
    end
    
    def add_follower user
    end
    
    def drop_follower user
    end

    
    module ClassMethods
      #mattr_reader :names
      
      
      # usage:
      # follow_opts :position => <Fixnum> (starting at 1, default: add to end)
      def follow_opts opts
        codename = opts[:codename] || self.name.match(/::(\w+)$/)[1].underscore.to_sym
        if opts[:position]
          if Card::FollowOption.names[opts[:position]-1]
            Card::FollowOption.names.insert(opts[:position]-1, codename)
          else
            Card::FollowOption.names[opts[:position]-1] = codename
          end
        else
          Card::FollowOption.names << codename
        end
      end
    end   
  end
end
