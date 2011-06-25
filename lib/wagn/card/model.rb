
Wagn.send :include, Wagn::Exceptions

module Wagn::Card
  module Model
   include Wagn::Pack

   def self.included(base)
     STDERR << "Loading pack models #{base}\n\n"
     base.extend Wagn::Card::ModuleMethods
     base.superclass.extend Wagn::Card::ActsAsCardExtension
     unless base.include?(Wagn::Card::AttributeTracking)
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
   end
  end
end



