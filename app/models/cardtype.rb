class Cardtype < ActiveRecord::Base
  acts_as_card_extension
  
  # FIXME -- the current system of caching cardtypes is not "thread safe":
  # multiple running ruby servers could get out of sync re: available cardtypes  
  
  def after_create
    Card.send(:load_cardtypes!)
  end
  
  def after_destroy
    Card.send(:load_cardtypes!)
  end
  
end
