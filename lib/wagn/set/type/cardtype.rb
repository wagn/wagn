module Wagn::Set::Type::Cardtype
  include Wagn::Set::Type::Basic

  def on_type_change
    custom_validate_destroy
  end

  def validate_type_change
    custom_validate_destroy
  end

  def cards_of_type_exist?
    Session.as_bot { Card.count_by_wql :type_id=>id } > 0 
  end

  def custom_validate_destroy
    if cards_of_type_exist?
      errors.add :cardtype, "can't be altered because #{name} is a Cardtype and cards of this type still exist"
      false
    else
      true
    end
  end

end
