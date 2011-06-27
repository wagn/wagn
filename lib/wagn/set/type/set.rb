module Wagn::Set::Type
  module Set
    def self.included(base)
      Rails.logger.debug "including Set -> Search #{self} #{base}"
      base.send :include, Wagn::Set::Type::Search
    end
  end
end
