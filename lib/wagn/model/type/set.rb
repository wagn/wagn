module Wagn::Model::Type
  module Set
    def self.included(base)
      Rails.logger.debug "including Set -> Search #{self} #{base}"
      base.send :include, Wagn::Model::Type::Search
    end
  end
end
