module Sol

  attr_reader :solcard

  def receive_breath(cards)
    if sol = solcard and
        !sol.integrate(sol.parse_fields(cards))
      render_card_errors(sol)
      return false
    end
    true
  end

  def parse_fields(cards)
    opts={}
    ctxname = Regexp.escape(trunk.name) if trunk
    solname = Regexp.escape(name)
    cards.each_pair do |name, value|
      name = name.post_cgi.to_absolute(name)
      name.sub!(/^#{solname}\+/,'CTXSOL+') if ctxname
      name.sub!(/^#{ctxname}\+/,'CTX+')
      type, content = value[:type], value[:content]
#Rails.logger.info("Post field: #{name} => #{type}::#{content}")
      opts[name] = content
    end
    opts
  end

  def integrate(opts)
    Rails.logger.info("Integrate breath to my context: #{opts.inspect}")
  end

  def self.included(base)
#Rails.logger.info("add_extension from Sol #{base.inspect}")
    Card.add_extension_tag('*sol', :declare)
  end

  def has_sol?() true if solcard end
  def solcard() @solcard ||= extcard('*sol') end
end

CardController.class_eval do
  #----------------( Posting Currencies to Cards )
  def declare
    id = Cardname.unescape(params['id'] || '')
    raise("Need a card to receive declarations") if id.nil? or
                        id.empty?
    raise("Can't find card") unless @card = Card.find_by_id(id)
Rails.logger.info("Declare #{@card && @card.name} #{@card && @card.inspect}")
    @card.receive_breath(params['cards']) if params['multi_edit']
  end
end

Card::Base.send :include, Sol

