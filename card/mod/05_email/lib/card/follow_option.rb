# -*- encoding : utf-8 -*-


class Card
  module FollowOption
    #mattr_reader :codenames
    @@options = { :all=>[], :main=>[], :restrictive=>[] }
    
    def self.included(host_class)     
       host_class.extend ClassMethods
    end
    
    def self.codenames type=:all
      @@options[type]
    end
    
    def self.cards
       codenames.map { |codename| Card[codename] }
    end
    
    def self.restrictive_options
      self.codenames :restrictive
    end
    
    def self.main_options
      self.codenames :main
    end
    
    def restrictive_option?
      Card::FollowOption.restrictive_options.include? codename
    end

    def description set_card
      set_card.follow_label
    end

    module ClassMethods
      
      # args:
      # :position => <Fixnum> (starting at 1, default: add to end)
      def restrictive_follow_opts args
        add_option args, :restrictive
      end
      
      # args:
      # :position => <Fixnum> (starting at 1, default: add to end)
      def follow_opts args
        add_option args, :main
      end
      
      private
      
      def insert_option pos, item, type
        if Card::FollowOption.codenames(type)[pos]  
          Card::FollowOption.codenames(type).insert(pos, item)
        else  
          # If pos > codenames.size in a previous insert then we have a bunch of preceding nils in the array.
          # Hence, we have to overwrite a nil value if we encounter one and can't use insert.
          Card::FollowOption.codenames(type)[pos] = item
        end
      end
      
      def add_option opts, type
        codename = opts[:codename] || self.name.match(/::(\w+)$/)[1].underscore.to_sym
        if opts[:position]
          insert_option opts[:position]-1, codename, type
        else
          Card::FollowOption.codenames(type) << codename
        end
        Card::FollowOption.codenames(:all) << codename
      end
      
    end   
  end
end
