require_dependency 'json'

mattr_accessor :setting_groups

@@setting_groups = { :permission =>[], :look_and_feel=>[], :communication => [], :pointer=>[], :other =>[] }

SETTING_GROUP_NAMES = {
  :permission    => "Permission",
  :look_and_feel => "Look and Feel",
  :communication => "Communication",
  :pointer       => "Pointer",
  :other         => "Other"  
}


def all_cardtype_ids
  Card.find_all_by_type_id(Card::CardtypeID).map(&:id)
end

def to_type_id type
  type.is_a?(Fixnum) ? type : Card.find_by_key(type)
end

def self.extended(host_class)
  host_class.mattr_accessor :invisible_for, :rule_type_editable, :codename

  def host_class.set_setting opts
    group = opts[:group] || :other
    setting_groups[group] ||= []

    if opts[:position]
      if setting_groups[group][opts[:position]-1]
        setting_groups[group].insert(opts[:position]-1, self)
      else
        setting_groups[group][opts[:position]-1] = self
      end
    else
      setting_groups[group] << self
    end
    
    self.codename = opts[:codename] || self.name.match(/::(\w+)$/)[1].underscore.to_sym
    self.rule_type_editable = opts.key?(:rule_type_editable) ? opts[:rule_type_editable] : true
    self.invisible_for = !opts.key?(:visible) ? [] :  # default is visible
      if opts[:visible].is_a? Hash
        if opts[:visible][:only]
          ::Set.new(all_cardtype_ids) - ::Set.new([opts[:visible][:only]].flatten.map{ |cardtype| to_type_id(cardtype) })
        elsif opts[:visible][:except]
          ::Set.new([opts[:visible][:except]].flatten.map{ |cardtype| to_type_id(cardtype) })
        else
          []
        end
      else  # true or false
         opts[:visible] ? [] : ::Set.new(all_cardtype_ids)
      end
  end
end


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
    #{ _render_closed_content args }
    <table class="setting-rules">
      <tr><th>Set</th><th>Rule</th></tr>
      #{
        klasses.map do |klass, rules|
          %{ 
            <tr class="klass-row anchorless-#{ klass.anchorless? }">
              <td class="setting-klass">#{ klass.anchorless? ? link_to_page( klass.pattern ) : klass.pattern }</td>
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

