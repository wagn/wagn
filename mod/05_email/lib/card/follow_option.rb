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

    # def follower_ids
    #   All::Follow.read_reversed_following_cache(key) || begin
    #     ids = Card.joins(:references_to).where(
    #         :card_references => { :referee_key => key},
    #         :right_id=>Card[:following].id ).pluck(:left_id)
    #     All::Follow.write_reversed_following_cache(key, ::Set.new(ids))
    #   end
    # end
    #
    
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
