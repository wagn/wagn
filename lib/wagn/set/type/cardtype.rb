module Wagn::Set::Type::Cardtype
  include Wagn::Set::Type::Basic
                                       
  # codename should not change, but let's remove this with the codename refactor
  def codename
    extension ? extension.class_name : nil
  end

  def codename=(codename)
    extension.class_name = codename
    extension.save
  end

  def create_extension
    return unless typecode == 'Cardtype'  #hack
    codename = Card.generate_codename_for(name)
    #Rails.logger.debug "Cardtype extension #{name} #{codename}"
    self.extension = ::Cardtype.create!( :class_name => codename )
  end
  
  def reset_cardtype_cache
    Cardtype.cache.reset
  end

  
  def on_type_change
    validate_destroy && destroy_extension && reset_cardtype_cache
  end

  def validate_type_change
    validate_destroy
  end

  def cards_of_type_exist?
    Card.find_by_typecode_and_trash( extension.codename, false )
  end
   
  private
    
  def validate_destroy
    if extension and cards_of_type_exist?
      errors.add :cardtype, "can't be altered because #{name} is a Cardtype and cards of this type still exist"
      false
    else
      true
    end
  end
  
  
end
