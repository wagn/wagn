module Sol

  attr_reader :solcard

  def receive_breath(sig,br_name,cards)
    if sol = solcard and
        !sol.integrate(sol.parse_fields(sig, br_name,cards))
      render_card_errors(sol)
      return false
    end
    true
  end

  def signature
    # compute sha1 signature of content
    sha1 = Digest::SHA1.hexdigest(content)
    Rails.logger.info("signature(#{sha1})")
    sha1
  end

  def identity_sig
    # compute sha1 signature of identity content
    ident_data = 'aaaaDUMMYIDENTbbbbb'
    sha1 = Digest::SHA1.hexdigest(ident_data)
  end

  def previous_idsig(sig)
    # seach through revision history of this solcard for one, and return a rev.
    rev = current_revision
    if rev.content.match(/\bidsig="([^"]*)"/)
      CGI.unescapeHTML($~[1])
    else
      identity_sig
    end
  end

  def parse_fields(sig, br_name,cards)
    prefix = Regexp.escape(name)
    prefix = "(#{prefix}|#{Regexp.escape(trunk.name)})\\+" if trunk
    br_opts = {:name=>br_name, :ctx=>sig, :idsig=>previous_idsig(sig)}
Rails.logger.info("Pp: #{prefix} : #{identity_sig} :: #{br_opts[:oldsig]}")
    #raise "sig changed" if br_opts[:oldsig] != identity_sig
    out = Builder::XmlMarkup.new.breath(br_opts) do |b|
      cards.each_pair do |name, value|
        name = name.post_cgi.to_absolute(name)
        symbol1 = name.sub(/^#{prefix}/,'') ; symbol= symbol1.gsub(/\+/,'_')
        symbol = name.sub(/^#{prefix}/,'').gsub(/\+/,'_')
        type, content = value[:type], value[:content]
Rails.logger.info("Post field:#{name}::#{symbol}:#{symbol}=>#{content}")
	b.tag!(symbol, content)
      end
    end
Rails.logger.info("parse field: #{br_name} => #{out.to_s}")
    out
  end

  def integrate(opts)
    Rails.logger.info("Integrate breath to my context: #{opts.inspect}")

    update_attributes!(:content =>opts.to_s) # save xml to sol card content
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
    card_args=params[:card] || {}
    unless @card
      Rails.logger.info("declare fetch card by id")
      id = Cardname.unescape(params['id'] || '')
      raise("Need a card to receive declarations") if id.nil? or id.empty?
      raise("Can't find card") unless @card = Card.find_by_id(id)
    end
    raise "no card #{card_args.inspect}" unless @card
    #fail "card params required" unless params[:card] or params[:cards]

    # ~~~ REFACTOR! -- this conflict management handling is sloppy
    @current_revision_id = @card.current_revision.id
    old_revision_id = card_args.delete(:current_revision_id) || @current_revision_id
    rev_changed = (old_revision_id.to_i != @current_revision_id.to_i)

Rails.logger.info("Declare #{@card && @card.name} #{@card && @card.inspect}")
    @card.receive_breath(params[:ctxsig],params[:attribute],params['cards']) if params['multi_edit']
  end
end

Card::Base.send :include, Sol

