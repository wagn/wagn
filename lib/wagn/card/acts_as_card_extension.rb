module Wagn::Card::ActsAsCardExtension
  # extend with this one, just class methods
=begin
def self.included(base)
  super
  base.extend(ClassMethods)
end
=end

  def acts_as_card_extension( options = {})
    has_one :card, :as=>:extension
    class_eval do
      def cardname
        if card 
          card.name
        else 
          name = respond_to?(:codename) ? codename : "#{self.class} #{self.id}"
        #  warn "#{name} should have had a card!"
          name
        end
      end

    end

  end
end
