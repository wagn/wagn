
format do
  def show view, args
    view ||= :core
    render view, args
  end

  # NAME VIEWS
                                                                              
  view :name,     :perms=>:none  do |args|  card.name                    end
  view :codename, :perms=>:none  do |args|  card.codename.to_s           end  
  view :key,      :perms=>:none  do |args|  card.key                     end
  view :id,       :perms=>:none  do |args|  card.id                      end
  view :type,     :perms=>:none  do |args|  card.type_name               end
  view :linkname, :perms=>:none  do |args|  card.cardname.url_key        end
  view :url,      :perms=>:none  do |args|  wagn_url _render_linkname    end
  view :title,    :perms=>:none  do |args|  args[:title] || card.name    end
  view :url_link, :perms=>:none  do |args|  build_link wagn_url(_render_linkname) end

  view :link, :perms=>:none do |args|
    card_link card.name, showname( args[:title] ), card.known?, args[:type]
  end


  # DATE VIEWS

  view :created_at, :perms=>:none do |args| time_ago_in_words card.created_at end
  view :updated_at, :perms=>:none do |args| time_ago_in_words card.updated_at end
  view :acted_at,   :perms=>:none do |args| time_ago_in_words card.acted_at   end
    


  # CONTENT VIEWS

  view :raw do |args|
    scard = args[:structure] ? Card[ args[:structure] ] : card
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

  view :closed_content do |args|
    Card::Content.truncatewords_with_closing_tags _render_core(args) #{ yield }
  end


  # note: content and open_content may look like they should be aliased to core, but it's important that they render
  # core explicitly so that core view overrides work.  the titled and labeled views below, however, are not intended
  # for frequent override, so this shortcut is fine.


  # NAME + CONTENT VIEWS

  view :titled do |args|
    "#{ card.name }\n\n#{ _render_core args }"
  end
  view :open, :titled

  view :labeled do |args|
    "#{ card.name }: #{ _render_closed_content args }"
  end
  view :closed, :labeled


  # SPECIAL VIEWS

  view :array do |args|
    card.item_cards(:limit=>0).map do |item_card|
      subformat(item_card)._render_core(args)
    end.inspect
  end


  view :blank,          :perms=>:none do |args| '' end
    
  

  #none of the below belongs here!!


  view :template_rule, :tags=>:unknown_ok do |args|
    #FIXME - relativity should be handled in smartname
  
    name = args[:inc_name] or return ''
    regexp = /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/
    absolute = name !~ regexp && name !~ /^\+/
    
    tname = name.gsub regexp, ''
    if tname !~ /^\+/ and !absolute
      "{{#{args[:inc_syntax]}}}"
    else
      set_name = if absolute # find the most appropriate set to use as prototype for inclusion
        "#{name}+#{Card[:self].name}"
      else
        tmpl_set_name = parent.card.cardname.trunk_name
        if tmpl_set_class_name = tmpl_set_name.tag_name and Card[tmpl_set_class_name].codename == 'type'
          "#{tmpl_set_name.left_name}#{name}+#{Card[:type_plus_right].name}"  # *type plus right
        else
          "#{tname.gsub /^\+/,''}+#{Card[:right].name}"                                      # *right
        end
      end
    
      subformat( Card.fetch(set_name) ).render_template_link args
    end
  end
end
