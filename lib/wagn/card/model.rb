
include Wagn::Cardname # loads string methods for cardnames

module Wagn::Card::Model
  def self.append_features(base)
    base.extend Wagn::Card::ModuleMethods
    base.superclass.extend Wagn::Card::ActsAsCardExtension
    base.send :include, Wagn::Card::AttributeTracking
    base.send :include, Wagn::Card::CardAttachment
    base.send :include, Wagn::Card::Exceptions
    base.send :include, Wagn::Card::TrackedAttributes
    base.send :include, Wagn::Card::Templating
    base.send :include, Wagn::Card::Defaults
    base.send :include, Wagn::Card::Permissions
    base.send :include, Wagn::Card::Search
    base.send :include, Wagn::Card::References
    base.send :include, Wagn::Card::Cacheable
    base.send :include, Wagn::Card::Settings
    base.send :include, Wagn::Card::Fetch
  end
  
  # Does the model need the packs? I don't think so ...
  #include Wagn::Pack
end

Wagn.send :include, Wagn::Exceptions


