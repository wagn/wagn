module Wagn::Set::Type::File
  def self.included(base)
    super
    Rails.logger.debug "included(#{base}) #{self}"
    base.class_eval { card_attachment CardFile }
  end
  
  def item_names(args={})
    [self.name]
  end
end
