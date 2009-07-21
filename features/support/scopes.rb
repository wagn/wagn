module ScopeHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def scope_of(section)
    case section
    
    when /the main card content/
      '#main .card-slot .content'
    
    when /the main card footer/
      '#main .card-slot .card-footer'
      
    else
      raise "Can't find mapping from \"#{section}\" to a scope.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(ScopeHelpers)