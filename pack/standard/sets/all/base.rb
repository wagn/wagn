# -*- encoding : utf-8 -*-

### ---- Core renders --- Keep these on top for dependencies

view :show, :perms=>:none  do |args|
  render( ( args[:view] || :core ), args )
end

view :raw do |args|
  scard = args[:structure] ? Card[ args[:structure] ] : card
  scard ? scard.raw_content : _render_blank
end

view :core     do |args|  process_content _render_raw(args)            end
view :content  do |args|  _render_core args                            end
  # this should be done as an alias, but you can't make an alias with an unknown view,
  # and base format doesn't know "content" at this point
view :titled   do |args|  card.name + "\n\n" + _render_core(args)      end
                                                                              
view :name,     :perms=>:none  do |args|  card.name                    end
view :codename, :perms=>:none  do |args|  card.codename.to_s           end
  
view :key,      :perms=>:none  do |args|  card.key                     end
view :id,       :perms=>:none  do |args|  card.id                      end
view :linkname, :perms=>:none  do |args|  card.cardname.url_key        end
view :url,      :perms=>:none  do |args|  wagn_url _render_linkname    end

view :link, :perms=>:none  do |args|
  card_link card.name, showname( args[:title] ), card.known?
end

view :open_content do |args|
  _render_core args
end

view :closed_content do |args|
  Card::Content.truncatewords_with_closing_tags _render_core(args) #{ yield }
end

###----------------( SPECIAL )
view :array do |args|
  card.item_cards(:limit=>0).map do |item_card|
    subformat(item_card)._render_core(args)
  end.inspect
end

view :blank, :perms=>:none do |args| "" end

view :not_found, :perms=>:none, :error_code=>404 do |args|
  %{ Could not find #{card.name.present? ? %{"#{card.name}"} : 'the card requested'}. }
end

view :server_error, :perms=>:none do |args|
  %{ Wagn Hitch!  Server Error. Yuck, sorry about that.\n}+
  %{ To tell us more and follow the fix, add a support ticket at http://wagn.org/new/Support_Ticket }
end

view :denial, :perms=>:none, :error_code=>403 do |args|
  focal? ? 'Permission Denied' : ''
end

view :bad_address, :perms=>:none, :error_code=>404 do |args|
  %{ 404: Bad Address }
end

view :no_card, :perms=>:none, :error_code=>404 do |args|
  %{ 404: No Card! }
end

view :too_deep, :perms=>:none do |args|
  %{ Man, you're too deep.  (Too many levels of inclusions at a time) }
end

# The below have HTML!?  should not be any html in the base format


view :closed_missing, :perms=>:none do |args|
  %{<span class="faint"> #{ showname } </span>}
end

view :missing, :perms=>:none do |args|
  %{<span class="faint"> #{ showname } </span>}
end

view :too_slow, :perms=>:none do |args|
  %{<span class="too-slow">Timed out! #{ showname } took too long to load.</span>}
end

view :template_rule, :tags=>:unknown_ok do |args|
  tname = args[:include_name].gsub /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/, ''
  if tname !~ /^\+/
    "{{#{args[:inclusion_syntax]}}}"
  else
    tmpl_set_name = parent.card.cardname.left_name
    set_name = # find the most appropriate set to use as prototype for inclusion
      if tmpl_set_class_name = tmpl_set_name.tag_name and Card[tmpl_set_class_name].codename == 'type'
        "#{tmpl_set_name.left_name}#{args[:include_name]}+#{Card[:type_plus_right].name}"  # *type plus right
      else
        "#{tname.gsub /^\+/,''}+#{Card[:right].name}"                                      # *right
      end
    subformat( Card.fetch(set_name) ).render_template_link args
  end
end
