
format :html do
  view :core do |args|
    %{
      <h2>#{#msg}
      }</h2>
      <p>cards: #{Card.where(:trash=>false).count}</p>
      <p>trashed cards: #{Card.where(:trash=>true).count}</p>
      <p>revisions: #{Card::Revision.count}</p>
      <p>references: #{Card::Reference.count}</p>
    }
  end
end