Wagn.send :include, Wagn::Exceptions

module Wagn::Model

  def self.included(base)
    base.send :include, Wagn::Model::AttributeTracking
    base.send :include, Wagn::Model::Collection
    base.send :include, Wagn::Model::Exceptions
    base.send :include, Wagn::Model::Fetch
#    base.send :include, Wagn::Model::Traits
    base.send :include, Wagn::Model::Templating
    base.send :include, Wagn::Model::TrackedAttributes
    base.send :include, Wagn::Model::Permissions
    base.send :include, Wagn::Model::References
    base.send :include, Wagn::Model::Settings
    base.send :include, Wagn::Model::Pattern
    base.send :include, Wagn::Model::Attach
  end
end

