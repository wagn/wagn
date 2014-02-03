view :setup, :tags=>:unknown_ok do |args|
  account = User.new( ( params[:card] && params[:card][:account_args] ) || {} )
  frame_args = {
    :title=>'Welcome, Wagneer!',
    :show_help=>true,
    :optional_menu=>:never, 
    :help_text=>'To get started, set up an account.'
  }
    
  wrap_frame :setup, frame_args do
    form_for :card do |f|
      @form = f
      %{
        #{ _render_name_editor :help=>'usually first and last name' }
        #{ hidden_field_tag 'card[type_id]', Card.default_accounted_type_id }
        #{ _render_account_detail :account=>account, :setup=>true }
        <fieldset><div class="button-area">#{ submit_tag 'Create' }</div></fieldset>
        #{ render_error }
      }
    end
  end
end

view :show_cache do |args|
  wrap_frame :show_cache, args do 
    key = card.key
    cache_card = Card.fetch(key)
    db_card = Card.find_by_key(key)
    
    table = if cache_card && db_card
      %{<table class="show-cache">
          <tr><th>Field</th><th>Cache Val</th><th>Database Val</th></tr>
          #{
            [ :name, :updated_at, :updater_id, :current_revision_id, :content ].map do |field|
              %{<tr>#{ [ field, cache_card.send(field), db_card.send(field) ].map() { |cell| "<td>#{cell}</td>"}.join }</tr>}
            end.join
          }
        </table>
      }
    end
  
    %{
      <h1>Cache/DB Comparison</h1>
      #{ table }
      
      <h1>Cached Card Inspect</h1>
      #{ h cache_card.inspect }

      <h1>Database Card Inspect</h1>
      #{ h db_card.inspect }
     }
  end
end
