# -*- encoding : utf-8 -*-
module Wagn

  class Renderer::Html
    private

    def find_current_rule_card
      # self.card is a POTENTIAL rule; it quacks like a rule but may or may not exist.
      # This generates a prototypical member of the POTENTIAL rule's set
      # and returns that member's ACTUAL rule for the POTENTIAL rule's setting
      set_prototype = card.trunk.prototype
      rule_card = if card.new_card?
        setting = card.right and set_prototype.rule_card setting.codename   
      else
        card
      end 
      [ rule_card, set_prototype ]
    end
  end
end
