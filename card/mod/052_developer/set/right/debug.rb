def virtual?
  true
end

format :html do
  view :core do |_args|
    subject = card.left
    [
      ["Set Modules", subject.set_modules],
      ["Set Patterns", subject.patterns.map(&:to_s)],
      ["Events",
       static_tabs(create: "<pre>#{subject.events(:create)}</pre>",
                   update: "<pre>#{subject.events(:update)}</pre>",
                   delete: "<pre>#{subject.events(:delete)}</pre>")],
      ["Cache/DB Comparison", comparison_table(subject)]
    ].map { |item| section(*item) }
  end

  def comparison_table subject
    cache_card = Card.fetch(subject.key)
    db_card    = Card.find_by_key(subject.key)
    return unless cache_card && db_card
    table(
      [:name, :updated_at, :updater_id, :content, :inspect].map do |field|
        [field.to_s,
         h(cache_card.send(field)),
         h(db_card.send(field))]
      end,
      header: ["Field", "Cache Val", "Database Val"]
    )
  end

  def section title, content
    %(
      <h2>#{title}</h2>
      #{content}
    )
  end
end
