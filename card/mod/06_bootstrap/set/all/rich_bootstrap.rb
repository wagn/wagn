format :html do
  
  view :closed do |args|
    args.merge! :body_class=>'closed-content'
    super args
  end
  
  
  view :confirm_rename do |args|
    referers = args[:referers]
    dependents = card.dependents
    wrap args do
      %{
        <h5>Are you sure you want to rename <em>#{card.name}</em>?</h5>
        #{ %{ <h6>This change will...</h6> } if referers.any? || dependents.any? }
        <ul>
          #{ %{<li>automatically alter #{ dependents.size } related name(s). } if dependents.any? }
          #{ %{<li>affect at least #{referers.size} reference(s) to "#{card.name}".} if referers.any? }
        </ul>
        #{ %{<p>You may choose to <em>update or ignore</em> the references.</p>} if referers.any? }
      }
    end
  end
end