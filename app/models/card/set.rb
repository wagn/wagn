module Card::Set
  def self.included(base)
    Rails.logger.debug "including Set -> Search #{self} #{base}"
    base.send :include, Card::Search
  end
end
