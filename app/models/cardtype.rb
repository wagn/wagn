class Cardtype < ActiveRecord::Base
  acts_as_card_extension
  def codename
    class_name
  end
end
