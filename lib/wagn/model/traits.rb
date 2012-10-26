module Wagn::Model::Traits
  def self.included(base)
    super
    Rails.logger.debug "add card methods for traits #{base} #{self}"
    # class hash to register the traits, and the registration function
    base.extend(CardMethods)
  end

  module CardMethods
    def register_trait(trait_name, *options)
      options = options[0] if options.length == 1
      trait_options[trait_name] = options
      Rails.logger.debug "register_trait(#{trait_name}, #{options.inspect})"
      @menu_options=nil
    end
  
    def trait_options()  @@trait_options ||= {}; end
  end

#  def trait_card(trait_name)
#    if (trait_card=trait_cards[trait_name.to_sym]).nil?
#      trait_cards[trait_name.to_sym] = f = Card.fetch([name, trait_name].to_name)
#      Rails.logger.debug "trait_card(#{trait_name}, #{name}) #{f}"; f
#    else trait_card end
#  end
#
#  def trait_cards()    @trait_cards ||= {}; end
     
  def traits
    trait_options.keys.map do |trait_name|
      if tc=trait_card(trait_name) and tc.real?
        Rails.logger.info("tag_trait: #{name} + #{trait_name} #{tc.name}")
        block_given? ? yield(trait_name, tc) : trait_name
      end
    end.compact
  end  
        
  # adds options to right-menu for traits
  def menu_options(options=nil)
    options = options.clone || []
    @menu_options ||= begin
      topts = self.class.trait_options
      Rails.logger.debug "menu_options(#{options.inspect}) #{topts.inspect}"
      topts.keys.each do |trait_name|
        if trait_opts = topts[trait_name] and
           tc = trait_card(trait_name) and tc.real?
          Rails.logger.info("menu_options N[#{name}] #{trait_name} #{trait_opts}")
          if Hash===trait_opts
            trait_opts.each_pair do |where, what|
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
              options.push(*trait_opts)
            end
          end
        end
      end
      Rails.logger.debug "menu_options >(#{options.inspect})"
      options
    end
  end
end
