# -*- encoding : utf-8 -*-
module Wagn  
  class Renderer::Html

    private

    def core_inherit_content args={}
      sc = args[:set_context]
      text = if sc && sc.tag_name.key == Card[:self].key
        begin
          task = card.tag.codename
          ancestor = Card[sc.trunk_name.trunk_name]
          links = ancestor.who_can( task.to_sym ).map do |card_id|
            link_to_page Card[card_id].name, nil, :target=>args[:target]
          end*", "
          "Inherit ( #{links} )"
        rescue
          'Inherit'
        end
      else
        'Inherit from left card'
      end
      %{<span class="inherit-perm">#{text}</span>}
    end
  end
end
