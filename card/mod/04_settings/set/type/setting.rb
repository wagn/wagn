require_dependency 'json'
  

view :core do |args|

  klasses = Card.set_patterns.reverse.map do |set_class|
    wql = { :left  => { :type =>Card::SetID },
            :right => card.id,
            #:sort  => 'content',
            
            :sort  => ['content', 'name'],
            :limit => 0
          }
    wql[:left][ (set_class.anchorless? ? :id : :right_id )] = set_class.pattern_id

    rules = Card.search wql
    [ set_class, rules ] unless rules.empty?
  end.compact


  
  %{ 
    #{ _render_rule_help args }
    <table class="setting-rules">
      <tr><th>Set</th><th>Rule</th></tr>
      #{
        klasses.map do |klass, rules|
          %{ 
            <tr class="klass-row anchorless-#{ klass.anchorless? }">
              <td class="setting-klass">#{ klass.anchorless? ? card_link( klass.pattern ) : klass.pattern }</td>
              <td class="rule-content-container">
                <span class="closed-content content">#{ subformat(rules[0])._render_closed_content if klass.anchorless? }</span>
              </td>
            </tr>
            #{
              unless klass.anchorless?
                previous_content = nil
                rules.map do |rule|
                  current_content = rule.db_content.strip
                  duplicate = previous_content == current_content
                  changeover = previous_content && !duplicate
                  previous_content = current_content
                  %{
                    <tr class="#{ 'rule-changeover' if changeover }">
                    <td class="rule-anchor">#{ card_link rule.cardname.trunk_name, :text=> rule.cardname.trunk_name.trunk_name }</td>
                    
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

view :rule_help do |args|
  %{<div class="alert alert-info">#{process_content_object "{{+*right+*help|content}}"}</div>}
end


view :closed_content do |args|
  render_rule_help
end

