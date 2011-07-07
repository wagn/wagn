module Wagn::Model::Traits
  def self.included(base)
    super
    Rails.logger.debug "add card methods for traits #{base} #{self}"
    # class hash to register the traits, and the registration function
    base.class_eval {
      cattr_accessor :trait_options 
      cattr_accessor :action_traits
    }
    base.extend(CardMethods)
  end

  module CardMethods
    def register_trait(trait_name, *options)
      options = options[0] if options.length == 1
      trait_options[trait_name] = options
      @menu_options=nil
    end
  end

  # and this
  # was in Card::Base
  # A card has a 'trait' if card+trait_name exists
  def trait_card(trait_name) 
    trait_cards[trait_name.to_sym] ||= fetch(name+JOINT+trait_name)
  end
#r= Rails.logger.info("trait_card #{self}, #{trait_name} = #{r}"); r
  def trait_cards() @trait_cards ||= []; end
  def has_trait?(trait_name) true if trait_card(trait_name); end
     
  def traits
    trait_options().keys.map do |trait_name|
      if tc=trait_card(trait_name) and not tc.missing?
        Rails.logger.info("tag_trait: #{name} + #{trait_name} #{tc.name}")
        block_given? ? yield(trait_name, tc) : trait_name
      end
    end.compact
  end  
        
  # adds options to right-menu for traits
  def menu_options(options=[])
    @menu_options ||= trait_options().keys.map do |trait_name|
      if trait_opts = trait_options()[trait_name] and
         tc = trait_card(traitname) and not tc.missing?
        trait_list = []
        Rails.logger.info("menu_options N: #{trait_name} #{trait_opts}")
        if Hash===trait_opts
          trait_opts.each_pair do |where, what|
            trait_list.push(*what)
            if where == :right
              options.push(*what)
            elsif where == :left
              options.unshift(*what)
            elsif Array === where
              action, location = where
              idx = 0
              if Symbol===location
                idx = options.index(location)
              elsif Fixnum===location
                idx = location
                idx = options.length+idx+1 if idx<0
              else raise "Location? #{location.class} #{location.inspect}"
              end
              if action == :left_of or action == :before
                idx = if idx then idx-1 else -1 end
              elsif action == :right_of or action == :after
                idx = options.length unless idx
              else raise "Action? #{action.inspect}"
              end
              idx = options.length if idx > options.length
              if idx < 0
                options.unshift(*what)
              else
                options[idx,0] = what
              end
            end
          end
        else
          if Array===trait_opts and trait_opts.length > 0 or trait_opts
            trait_list.push(*trait_opts)
            options.push(*trait_opts)
          end
        end
        action_traits[trait_name] = trait_list
      end
      options
    end
  end
end
