# map_controller v0.2

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
    done = {}
    cards = Card.all(:include => :current_revision, 
      :conditions => "name LIKE '%+related patterns' AND NOT trash")
    cards.each do |card|
      name = card.name.sub(/\+related patterns$/,'')
      card.current_revision.content.scan(/\[\[([^\]]*)\]\]/) do |related|
        content << name+"~->~"+related[0]
        done[name] = true
        done[related[0]] = true
      end
    end
    cards = Card.search(:type=>'Pattern')
    cards.each do |card|
      if (!done[card.name])
        content << card.name
      end
    end
    @content = content.join("\n")
  end
end
