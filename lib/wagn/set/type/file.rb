module Wagn::Set::Type::File
  def self.included(base)
    super
    Rails.logger.debug "included(#{base}) #{self}"
    base.class_eval do card_attachment CardFile end
  end
  
  def item_names(args={})
    [self.cardname]
  end
end
