module Wagn::Set::Type
  module Set
    def self.included(base)
      super
      Rails.logger.debug "included(#{base}) #{self}"
      base.send :include, Wagn::Set::Type::Search
    end
  end
end
