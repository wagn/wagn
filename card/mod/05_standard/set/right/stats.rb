
view :core do |args|
  if subject = card.left

    frame args do
      cache_card = Card.fetch(subject.key)
      db_card    = Card.find_by_key(subject.key)

      table = if cache_card && db_card
                %(<table class="show-cache">
                    <tr><th>Field</th><th>Cache Val</th><th>Database Val</th></tr>
                    #{[:name, :updated_at, :updater_id, :content].map do |field|
                        %(<tr>#{[field, cache_card.send(field), db_card.send(field)].map { |cell| "<td>#{cell}</td>" }.join}</tr>)
                      end.join}
                  </table>
                )
      end

      %(
        <h1>Cache/DB Comparison</h1>
        #{table}

        <h1>Cached Card Inspect</h1>
        #{h cache_card.inspect}

        <h1>Database Card Inspect</h1>
        #{h db_card.inspect}
       )
    end

  end
end
