# map_controller v0.3

# Changes from v0.2:
#   Add support for Pattern stages
#   Further WQLize and simplify db searches
#   Assume all Patterns have a +stage card.  This should be safe
#     since creating a Pattern creates a +stage card.  The
#     assumption eliminates the need for a separate search to
#     show Patterns that did not appear in a +related patterns card,
#     and thus also eliminates the need for the "done" checklist
#     used in that search.

# Changes from v0.1:
#   Derive from ApplicationController instead of ActionController::Base
#     so database switching by domain works.
#   Use more elegant and efficient representations of "content" and "done".
#   Include check for deleted ("trash") cards.
#   Use WQL to find unlinked Pattern cards in case "type" in the database
#     is not the type displayed in the UI.

class MapController < ApplicationController
  layout nil
  
  def show
    content = []
    Card.search(:right=>'related patterns').each do |card|
      pattern = card.name.trunk_name
      card.current_revision.content.scan(/\[\[([^\]]*)\]\]/) do |related|
        content << pattern+"~->~"+related[0]
      end
    end
    Card.search(:right=>'stage').each do |card|
      content << card.name.trunk_name+"~.stage="+card.content
    end
    @content = content.join("\n")
  end
end
