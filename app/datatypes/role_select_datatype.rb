class RoleSelectDatatype < Datatype::Base
  
  #register "RoleSelect"
  editor_type "RoleSelect"
  
  description %{ Choose as many roles as you like. }
  
  def allow_duplicate_revisions
    true
  end
  
  def content_for_rendering
    @card.content.split(',').collect do |key|
      name = Role.find_by_codename(key).cardname
      "[[#{name}]]"
    end.join(", ")
  end
  
end
