module Wagn::Set::Type::Role
  include Wagn::Set::Type::Basic
    
  def create_extension
    self.extension = ::Role.create( :codename => name )
  end
  
  private
      
  def on_type_change
    destroy_extension
  end
end
