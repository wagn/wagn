
format :css do
  def default_nest_view
    :raw
  end

  def show view, args
    view ||= :content
    render view, args
  end

  view :titled do |args|
    major_comment(%( Style Card: "#{card.name}" )) + _render_core(args)
  end

  view :content do |args|
    _render_core args
  end

  view :missing do |_args|
    major_comment "MISSING Style Card: #{card.name}"
  end

  view :import do |_args|
    voo.items[:view] = :import
    %{\n@import url("#{_render_url}");\n}
  end

  view :url, perms: :none do |args|
    path_opts = { format: :css }
    path_opts[:item] = voo.items[:view] if voo.items[:view]
    page_path card.cardname, path_opts
  end

  def major_comment comment, char="-"
    edge = %(/* #{char * (comment.length + 4)} */)
    main = %(/* #{char} #{comment} #{char} */)
    "#{edge}\n#{main}\n#{edge}\n\n"
  end
end
