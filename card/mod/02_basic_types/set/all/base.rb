
format do
  def show view, args
    view ||= :core
    render view, args
  end

  # NAME VIEWS

  simple_args = { closed: true, perms: :none }
  view(:name,     simple_args) { card.name                           }
  view(:key,      simple_args) { card.key                            }
  view(:title,    simple_args) { |args| args[:title] || card.name    }
  view(:linkname, simple_args) { card.cardname.url_key               }
  view(:url,      simple_args) { card_url _render_linkname           }
  view(:url_link, simple_args) { web_link card_url(_render_linkname) }
  view(:singular, simple_args) { card.name.singularize               }
  view(:plural,   simple_args) { card.name.pluralize                 }

  view :link, closed: true, perms: :none do |args|
    card_link(
      card.name,
      text: showname(args[:title]),
      known: card.known?,
      path_opts: { type: args[:type] }
    )
  end

  view(:codename, closed: true) { card.codename.to_s }
  view(:id,       closed: true) { card.id            }
  view(:type,     closed: true) { card.type_name     }

  # DATE VIEWS

  view(:created_at, closed: true) { time_ago_in_words card.created_at }
  view(:updated_at, closed: true) { time_ago_in_words card.updated_at }
  view(:acted_at,   closed: true) { time_ago_in_words card.acted_at   }

  # CONTENT VIEWS

  view :raw do |args|
    scard = args[:structure] ? Card[args[:structure]] : card
    scard ? scard.raw_content : _render_blank
  end

  view :core do |args|
    process_content _render_raw(args)
  end

  view :content do |args|
    _render_core args
  end

  view :open_content do |args|
    _render_core args
  end

  view :closed_content, closed: true do |args|
    Card::Content.truncatewords_with_closing_tags _render_core(args)
  end

  view :blank, closed: true, perms: :none do
    ''
  end

  # note: content and open_content may look like they should be aliased to
  # core, but it's important that they render core explicitly so that core view
  # overrides work.  the titled and labeled views below, however, are not
  # intended for frequent override, so this shortcut is fine.

  # NAME + CONTENT VIEWS

  view :titled do |args|
    "#{card.name}\n\n#{_render_core args}"
  end
  view :open, :titled

  view :labeled do |args|
    "#{card.name}: #{_render_closed_content args}"
  end
  view :closed, :labeled

  # SPECIAL VIEWS

  view :array do |args|
    card.item_cards(limit: 0).map do |item_card|
      subformat(item_card)._render_core(args)
    end.inspect
  end

  # none of the below belongs here!!

  view :template_rule, tags: :unknown_ok do |args|
    # FIXME: - relativity should be handled in smartname
    return '' unless args[:inc_name]
    name = args[:inc_name].to_name
    stripped_name = name.stripped.to_name

    if name.relative? && !stripped_name.starts_with_joint?
      # not a simple relative name; just return the original syntax
      "{{#{args[:inc_syntax]}}}"
    else
      set_name =
        case
        when name.absolute?
          "#{name}+#{Card[:self].name}" # *self set
        when type = on_type_set
          "#{type}#{name}+#{Card[:type_plus_right].name}" # *type plus right
        else
          "#{stripped_name.gsub(/^\+/, '')}+#{Card[:right].name}" # *right
        end
      subformat(Card.fetch set_name).render_template_link args
    end
  end

  def on_type_set
    return unless
      (tmpl_set_name = parent.card.cardname.trunk_name) &&
      (tmpl_set_class_name = tmpl_set_name.tag_name) &&
      (tmpl_set_class_card = Card[tmpl_set_class_name]) &&
      (tmpl_set_class_card.codename == 'type')

    tmpl_set_name.left_name
  end
end
