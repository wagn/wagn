# -*- encoding : utf-8 -*-
module ScopeHelpers
  def scope_of section
    case section

    when /main card content/
      "#main > .card-slot > .card-frame > .card-content"

    when /pointer card content/
      "#main > .card-slot > .card-frame > .card-content > .pointer-list"

    when /main card header/
      "#main > .card-slot > .card-frame > .card-header"

    when /main card menu/
      "#main > .card-slot > .menu-slot > .card-menu"

    when /main card toolbar/
      "#main > .card-slot > .card-frame > nav.toolbar"

    when /main card frame/
      "#main > .card-slot > .card-frame"

    else
      raise "Can't find mapping from \"#{section}\" to a scope.\n" \
            "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(ScopeHelpers)
