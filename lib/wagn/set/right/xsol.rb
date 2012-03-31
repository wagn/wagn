=begin
  module Wagn::Set::Right::Xsol -- Metacurrency flows for Wagn

  This can be generalized just a little and be suitable for adding to almost
  any content management system with user editable content.

  How It Works

  At its most stripped down level, the atomic unit of a flow is a declaration
  from one autonomous entity to one of more other entities, or diagramatically:

  Source -> Utterance -> Destination

  Something is said by someone in an interpretive context.  In Wagn, a User
  or a Role the user is connected to would represent potential sources, and
  potentially any card is a destination "context".  The subject of the
  structure of an utterance (or breath if you prefer the Sols breathing
  together metaphor).

  The source and destination are cards in Wagn, as will be all addressable
  entities of the metacurrency rules and data.  Wagn makes it easy to add
  associated data to any card, the plus card, and this module uses the
  general idea of an "extension card" so that any card with a +*sol attached
  becomes a metacurrency endpoint.

  Identity

  The identity of the source and destination are represented by the xml
  rendering of the solcard (<Card>+*sol.xml) and the sha1 signature of this
  representation will be used in the protocal to identify sources and
  destinations.  This identifying data can change, so the identity signatures
  recorded with flows represent the identity data at the time the flows
  were created.
  
  Flows

  The extension adds controller actions to support the posting of flow
  actions from the current users or his/her roles to any card with a +*sol
  extension.  A "Declare" tab is added to the card menu, and when you select
  it you get a form.  The submenu options are more forms that represent
  different kinds of declarations you can make directed at this card.  Each
  form is controlled by another card which works like a template and
  multi-edit.

  So, we get a form with a set of "cards" and the name of a subaction
  along with the sha1 signature representing the current state of the
  receiving context.  The module simply formats this data including the
  from and to signatures as xml and posts that as the new current revision
  of the +*sol card.

  This represents a raw currency flow with no filtering or processing via
  open rules.  It simply takes in the flow elements and links them together
  with signatures.  The current contents of the +*sol card refers to the
  previous contents via its signature.  This will not always be the next
  most recent revision of the +*sol card, but the previous one in this flow
  sequence.  The point is that the ability to view these card revisions as
  they are generated, gives a verifyable witness to the flows as they
  happened and any tampering would break the signature chains.  This is
  the basis for the integrity of the metacurrency flows.

  Metacurrency Rules

  At this point, the metacurrency system will take over.  A Wagn::Hook will
  be called for the :after_declare event, and the metacurrency system would
  then further process the incoming "breath" according to the rules.  One
  thing that might happen is that it would redirect the user to a different
  page (by default, the declare controller returns for more declarations of
  the same kind).  That way posting a new proposal to an Intention card
  would create a new Proposal card and direct the user to it.

  The Rules can also be used to determine what options to present to the user.
  Based on what declarations the context accepts from the user and his/her
  roles, the appropriate submenus and forms would be generated automatically.

  This part isn't implemented at all yet, this is the big next challenge, to
  write the basic Rules engine.

  Extensions as they Work in this Prototype

  The "general" parts of the card based extension are part of the card model,
  a proposed part of the extension API to be refactored into something even
  more general.  This is how a module would add an extension:
 
Module Sol
  def self.included(base)
    Card.register_trait('sol', :declare)
  end
end

  This adds the menu option "Declare" the routes to the card_controller
  action "declare" (implemented below for Sol).  The :declare part can
  be more complex to add it at absolute or relative locations in the
  list.  If a card has more than one extension, each extension adds
  its options (starting from the default list passed to menu_options).

  Submenus

  Probably not the long term solution for this, but it works pretty well.
  It is keyed by the menu name (:declare above), and uses a setting based
  on that name, *declare to populate the submenus.  That setting should be
  a Pointer card, and for each pointee that exists, the submenu option is
  the tagname (or cardname if no plus), and the contents of the card is
  the form for that option.

  It needs a Hook here so the modules can do this according to its own rules,
  and this may still be a workable fallback when the Hook.call doesn't
  provide this function.
=end

module Wagn::Set::Right::Xsol

  def self.included(base)
    super
    base.register_trait('sol', :declare)
    Rails.logger.debug "including Sol #{base}"
=begin
    Wagn::Hook.add(:after_declare, '*all') do |card|
Rails.logger.info "after_declare #{card.name} C:#{card.solcard.content}"
    end
=end

    base.class_eval { attr_accessor :ctxsig, :attribute }
    base.send :before_save, :receive_breath
    #----------------( Posting Currencies to Cards )
    # 
Rails.logger.debug "Loading sol module ..."
  end

  def receive_breath
Rails.logger.debug "receive_breath, sol module ..."
    if ctxsig and attribute and cards
      #Wagn::Hook.call :before_declare, rec
#Rails.logger.info("Declare #{rec && rec.name}[#{rec}] #{rec && rec.inspect}")
      #Wagn::Hook.call :after_declare, rec
      raise Wagn::FinishAction if integrate(parse_fields(ctxsig, attribute, cards))

      errors[:breath].add "Error integrating breath"
    end
  end

  def integrate(xml)
#Rails.logger.info("Integrate breath to my context: #{xml.to_s}\nI:#{xml.inspect}")
    update_attributes(:content =>xml.to_s) # save xml to sol card content
  end

  # transforms "declaration" multi-form into xml output
  def parse_fields(sig, breath_name, cards)
    prefix = "(#{Regexp.escape(name)}|#{Regexp.escape(name.trunk_name)})\\+" if name.junction?
    unless user_sol = Card.user_card and user_sol=user_sol.trait_card(:sol)
      raise "Sending user has no sol card"
    end
    breath_attrs = {:name=>breath_name, :ctx=>sig,
               :fromsig=>user_sol.from_sig,
               :tosig=>previous_idsig(sig)}
    #raise "sig changed" if breath_attrs[:oldsig] != to_sig
#Rails.logger.info "parse_fields #{name}:#{user_card.name}:#{user_card.solcard.name}"
    Builder::XmlMarkup.new.breath(breath_attrs) do |b|
      cards.each_pair do |nm, value|
        nm = nm.post_cgi.to_absolute(nm)
        symbol = nm.sub(/^#{prefix}/,'').gsub(/\+/,'_')
        type, content = value[:type], value[:content]
        b.tag!(symbol, content)
      end
    end
  end

  # compute sha1 signature of content
  def signature()    Digest::SHA1.hexdigest(content) end
  def to_sig()       @to_sig ||= identity_sig end
  def from_sig()     @from_sig ||= identity_sig end
  def identity_sig() Digest::SHA1.hexdigest contextual_content(self, :xml) end

  def previous_idsig(sig)
    # seach through revision history of this solcard for one, and return a rev.
    rev = current_revision
    rev.content.match(/\bidsig="([^"]*)"/) ?  CGI.unescapeHTML($~[1]) : to_sig
  end

end
