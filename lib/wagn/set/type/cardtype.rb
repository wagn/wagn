module Wagn::Set::Type::Cardtype
  include Wagn::Set::Type::Basic

  def on_type_change
    validate_destroy
  end

  def validate_type_change
    validate_destroy
  end

  def cards_of_type_exist?
    Card.find_by_type_id_and_trash( id, false )
  end

  private

  def validate_destroy
    if cards_of_type_exist?
      errors.add :cardtype, "can't be altered because #{name} is a Cardtype and cards of this type still exist"
      false
    else
      true
    end
  end

end
