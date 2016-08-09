# -*- encoding : utf-8 -*-
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to page_name
    case page_name

    when /the home\s?page/
      "/"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(Auth[ $1 ])

    when /card (.*) with (.*) layout$/
      "/#{Regexp.last_match(1).to_name.url_key}?layout=$2"

    when /card (.*)$/
      "/#{Regexp.last_match(1).to_name.url_key}"

    when /new (.*) presetting name to "(.*)" and author to "(.*)"/
      url = "/new/#{Regexp.last_match(1)}?card[name]=#{Regexp.last_match(2).to_name.url_key}&_author=#{CGI.escape(Regexp.last_match(3))}"

    when /new card named (.*)$/
      "/card/new?card[name]=#{CGI.escape(Regexp.last_match(1))}"

    when /edit (.*)$/
      "/#{Regexp.last_match(1).to_name.url_key}?view=edit"

    when /rename (.*)$/
      "/#{$1.to_name.url_key}?view=edit_name"

    when /new (.*)$/
      "/new/#{Regexp.last_match(1).to_name.url_key}"

    when /kml source/
      "/House+*type+by_name.kml"

    when /url "(.*)"/
      Regexp.last_match(1).to_s

    else
      begin
        page_name =~ /the (.*) page/
        path_components = Regexp.last_match(1).split(/\s+/)
        send(path_components.push("path").join("_").to_sym)
      rescue Object => e
        raise "#{e.message} Can't find mapping from \"#{page_name}\" to a path.\n" \
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
