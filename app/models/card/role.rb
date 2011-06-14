class Card::Role < Card::Basic
  before_create :create_extension
  
  def create_extension
    self.extension = ::Role.create( :codename => name )
  end
  
  private
      
  def on_type_change
    destroy_extension
  end
end
