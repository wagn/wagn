format :json do
  def default_export_args args
    args[:count] ||= 0
    args[:processed_keys] ||= ::Set.new
  end

  # export the card itself and all nested content (up to 10 levels deep)
  view :export do |args|
    puts card.name.red
    # avoid loops
    return [] if args[:count] > 10 || args[:processed_keys].include?(card.key)
    args[:processed_keys] << card.key
    args[:count] += 1

    Array.wrap(render_content(args)[:card]).concat(
      render_export_items(count: args[:count])
    ).flatten
  end

  def default_export_items_args args
    args[:count] ||= 0
    args[:processed_keys] ||= ::Set.new
  end

  # export all nested content (up to 10 levels deep)
  view :export_items do |args|
    result = []
    each_nested_chunk do |chunk|
      next if chunk.respond_to?(:options) && chunk.options &&
              chunk.options[:inc_name] &&
              chunk.options[:inc_name] == '_main'
      next unless (r_card = chunk.referee_card)
      next if r_card.new? || r_card == card
      next if args[:processed_keys].include?(r_card.key)
      result << r_card
    end
    result.compact.uniq.map { |ca| subformat(ca).render_export(args) }
  end
end
