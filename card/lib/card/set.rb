# -*- encoding : utf-8 -*-

class Card
  #
  #  A 'Set' is a group of Cards to which 'Rules' may be applied.
  #  Sets can be as specific as a single card, as general as all cards, or
  #  anywhere in between.
  #
  #  Rules take two main forms: card rules and code rules.
  #
  #  'Card rules' are defined in card content. These are generally configured
  #  via the web interface and are thus documented at http://wagn.org/rules.
  #
  #  'Code rules' can be defined in a 'set module'. Card::Set supports
  #  creating and organizing these set modules.  It also provides an API for
  #  defining special methods within set modules.
  #
  #  Set modules follow the following naming convention:
  #
  #      MOD/set/PATTERN/ANCHOR[/FREENAME].rb
  #
  #  For example, suppose you created a "mod" (a Card modification) for managing
  #  your contacts called "contactmanager", and you wanted to write code
  #  that would apply to all +address cards.  You could add a file here:
  #
  #      ./contactmanager/set/right/address.rb
  #
  #  or here:
  #
  #      ./contactmanager/set/right/address/countries.rb
  #
  #  Then, whenever you fetch or instantiate a +address card, the card will
  #  automatically include code from that set module.  In fact, it will include
  #  all the set modules associated with sets of which it is a member.
  #
  #  For example, say you have a Plaintext card named 'Philipp+address', and
  #  you have set files for the following sets:
  #
  #      * all cards
  #      * all Plaintext cards
  #      * all cards ending in +address
  #
  #  When you run this:
  #
  #      mycard = Card.fetch 'Philipp+address'
  #
  #  ...then mycard will include the set modules associated with each of those
  #  sets in the above order.
  #
  #  You can quickly create a new set module running
  #
  #      `wagn generate set MOD PATTERN ANCHOR`
  #
  #  In the current example, this would translate to:
  #
  #      `wagn generate set contactmanager right address`.
  #
  #  Note that the set module's filename connects it to the set, so both
  #  the set_pattern and the set_anchor must correspond to the
  #  codename of a card in the database to function correctly.
  #
  #  A set module is "just ruby", but is generally quite concise because
  #  Card (a) uses its the set module's file location to autogenerate ruby
  #  module names and (b) then uses Card::Set module to provide API for the
  #  most common set methods.
  #
  module Set
    include Event
    include Trait
    include Basket
    include Inheritance

    include Set::Format
    include AdvancedApi
    include Helpers

    extend Loader

    mattr_accessor :modules, :traits
    self.modules = { base: [], base_format: {}, nonbase: {}, nonbase_format: {},
                     abstract: {}, abstract_format: {} }

    # SET MODULE API
    #
    # The most important parts of the set module API are views (see
    # Card::Set::Format) and events (see Card::Set::Event)
  end
end
