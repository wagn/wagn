module AjaxHelper
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #  
  def current_card
    current_url.match(/wagn\/(.*)/) 
    # FIXME
    'Home'
  end
  
  def params_for(control, section=nil)
    case control

    when /the watch link/
      ["/card/watch/#{current_card}", :post]

    when /the unwatch link/
      ["/card/unwatch/#{current_card}", :post]
    
    else
      raise "Can't find mapping from \"#{control}\" to parameters.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(AjaxHelper)