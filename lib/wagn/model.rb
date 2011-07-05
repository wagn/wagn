
Wagn.send :include, Wagn::Exceptions

module Wagn::Model
  include Wagn::Pack

  def self.included(base)
    base.extend Wagn::Model::ModuleMethods
    base.superclass.extend Wagn::Model::ActsAsCardExtension
    base.send :include, Wagn::Model::AttributeTracking
    base.send :include, Wagn::Model::CardAttachment
    base.send :include, Wagn::Model::Exceptions
    base.send :include, Wagn::Model::TrackedAttributes
    base.send :include, Wagn::Model::Traits
    base.send :include, Wagn::Model::Templating
    base.send :include, Wagn::Model::Defaults
    base.send :include, Wagn::Model::Permissions
    base.send :include, Wagn::Model::Search
    base.send :include, Wagn::Model::References
    base.send :include, Wagn::Model::Cacheable
    base.send :include, Wagn::Model::Settings
    base.send :include, Wagn::Model::Fetch
  end
end

