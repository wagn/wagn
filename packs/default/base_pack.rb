class Wagn::Renderer
  ### ---- Core renders --- Keep these on top for dependencies

  # update_references based on _render_refs, which is the same as 
  # _render_raw, except that you don't need to alias :refs as often
  # speeding up the process when there can't be any reference changes
  # (builtins, etc.)
  define_view(:raw) do card ? card.raw_content : _render_blank end
  define_view(:refs) do card.respond_to?('references_expired') ? card.raw_content : '' end
  define_view(:naked) do #|args|
    card.name.template_name? ? _render_raw : process_content(_render_raw)
  end
  alias_view(:naked, {}, :show, :content)
  define_view(:titled) do
    card.name + "\n\n" + _render_naked
  end

###----------------( NAME) 
  define_view(:name)     { card.name             }
  define_view(:key)      { card.key              }
  define_view(:linkname) { card.name.to_url_key  }
  define_view(:link)     { name=card.name; build_link(name, name) }
  define_view(:url)      { "#{System.base_url}/wagn/#{_render_linkname}"}


  define_view(:open_content) do |args|
    card.post_render(_render_naked(args) { yield })
  end

  define_view(:closed_content) do |args|
    @state = :line
    truncatewords_with_closing_tags( _render_naked(args) { yield } )
  end

###----------------( SPECIAL )
  define_view(:array) do |args|
    if card.collection?
      card.item_cards(:limit=>0).map do |item_card|
        subrenderer(item_card)._render_naked
      end
    else
      [_render_naked(args) { yield }]
    end.inspect
  end

  define_view(:blank) do "" end

  [ :deny_view, :edit_auto, :too_slow, :too_deep, :open_missing, :closed_missing ].each do |view|
    define_view(view) do |args|
      render_view_action view, args
    end
  end

  ## DEPRECATED
  # this is a quick fix, will soon be replaced by view override
  define_view(:when_created)     { card.new_card? ? '' : card.created_at.strftime('%A, %B %d, %Y %I:%M %p %Z') }
  define_view(:when_last_edited) { card.new_card? ? '' : card.updated_at.strftime('%A, %B %d, %Y %I:%M %p %Z') }
end
