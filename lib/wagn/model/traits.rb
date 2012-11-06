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
    end

    def trait_options()  @@trait_options ||= {}; end
  end

#  def trait_card(trait_name)
#    if (trait_card=trait_cards[trait_name.to_sym]).nil?
#      trait_cards[trait_name.to_sym] = f = Card.fetch([name, trait_name].to_cardname)
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
        
