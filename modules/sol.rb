class Card::Sol
  class << self

    def receive_breath(card, cards)
Rails.logger.info("RB #{self.inspect} ")
      if sol = Card::Sol.new(card.name) and
          !sol.breath_in(:incoming=>cards)
        render_card_errors(sol)
        return false
      end
      true
    end

    def new(args)
      Rails.logger.info("initialize Card::Sol #{args.inspect}")
      card = Card.fetch(args)
      solcard = card.extcard('*sol') if card
      card
    end
  end

  attr_accessor :solcard

  def breath_in(args)
    opts = {}.merge(args)
    Rails.logger.info("Breath in: #{opts.inspect}")  # breath(opts)
  end

  def self.included(base)
	  Rails.logger.info("add_extension from Sol #{base.inspect}")
    Card.add_extension_tag('*sol', :declare)
  end

  def has_sol?() true if solcard end
  def solcard() extcard('*sol') end
end

CardController.class_eval do
  #----------------( Posting Currencies to Cards )
  def declare
    id = Cardname.unescape(params['id'] || '')
    raise("Need a card to receive declarations") if id.nil? or
                        id.empty?
    raise("Can't find card") unless @card = Card.find_by_id(id) || Card.fetch(id)
Rails.logger.info("Declare #{@card && @card.name} #{@card && @card.inspect}")
    Card::Sol.receive_breath(@card, params['cards']) if params['multi_edit']
  end
end

Card.send :include, Sol

