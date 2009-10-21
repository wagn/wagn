module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      '/'

    when /recent changes/
      '/recent'
      
    when /card (.*)$/
      "/wagn/#{$1.to_url_key}"
    
    when /edit (.*)$/
      "/card/edit/#{$1.to_url_key}"  

    when /new (.*)$/
      "/new/#{$1.to_url_key}"
      
    when /url "(.*)"/
      "/#{$1}"
      
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
