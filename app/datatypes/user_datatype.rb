class UserDatatype < Datatype::Base
  
  register "User"
  editor_type "User"
  
  description %{
    Describe User datatype here.
  }
  def allow_duplicate_revisions
    true
  end
  
end
