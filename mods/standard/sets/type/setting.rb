require_dependency 'json'

POINTER_KEY = "Pointer"

SETTING_GROUPS = {
  "Permission"    => [ :create, :read, :update, :delete, :comment ],
  "Look and Feel" => [ :default, :structure, :layout, :style, :table_of_contents ],
  "Communication" => [ :help, :add_help, :send, :thanks ],
  POINTER_KEY     => [ :options, :options_label, :input ],
  "Other"         => [ :autoname, :accountable, :captcha ]
}


view :core do |args|

  klasses = Card.set_patterns.reverse.map do |set_class|
    wql = { :left  => { :type =>Card::SetID },
            :right => card.id,
            #:sort  => 'content',
            
            :sort  => ['content', 'name'],
            :limit => 0
          }
    wql[:left][ (set_class.anchorless? ? :id : :right_id )] = set_class.key_id

    rules = Card.search wql
    [ set_class, rules ] unless rules.empty?
  end.compact


  
  %{ 
    #{ _render_closed_content args }
    <table class="setting-rules">
      <tr><th>Set</th><th>Rule</th></tr>
      #{
        klasses.map do |klass, rules|
          %{ 
            <tr class="klass-row anchorless-#{ klass.anchorless? }">
              <td class="setting-klass">#{ klass.anchorless? ? link_to_page( klass.key_name ) : klass.key_name }</td>
              <td class="rule-content-container">
                <span class="closed-content content">#{ subformat(rules[0])._render_closed_content if klass.anchorless? }</span>
              </td>
            </tr>
            #{
              unless klass.anchorless?
                previous_content = nil
                rules.map do |rule|
                  current_content = rule.content.strip
                  duplicate = previous_content == current_content
                  changeover = previous_content && !duplicate
                  previous_content = current_content
                  %{
                    <tr class="#{ 'rule-changeover' if changeover }">
                    <td class="rule-anchor">#{ link_to_page rule.cardname.trunk_name.trunk_name, rule.cardname.trunk_name }</td>
                    
                      #{
                        if duplicate
                          %{ <td></td> }
                        else
                          %{
                            <td class="rule-content-container">
                              <span class="closed-content content">#{ subformat(rule)._render_closed_content }</span>
                            </td>
                          }
                        end
                      }
                    </tr>
                  }

                end * "\n"
              end
            
            }
          }
        end * "\n"
      
      }
    </table>
  }

end

view :closed_content do |args|
  %{<div class="instruction">#{process_content_object "{{+*right+*help}}"}</div>}
end

