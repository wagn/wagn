require_dependency "json"

def self.member_names
  @@member_names ||= begin
    Card.search(
      { type_id: SettingID, return: "key" },
      "all setting cards"
    ).each_with_object({}) do |card_key, hash|
      hash[card_key] = true
    end
  end
end

format :data do
  view :core do |_args|
    wql = { left:  { type: Card::SetID },
            right: card.id,
            limit: 0 }
    Card.search(wql).compact.map { |c| nest c }
  end
end

def set_classes_with_rules
  Card.set_patterns.reverse.map do |set_class|
    wql = { left:  { type: Card::SetID },
            right: id,
            # sort:  'content',

            sort:  %w(content name),
            limit: 0 }
    wql[:left][(set_class.anchorless? ? :id : :right_id)] = set_class.pattern_id

    rules = Card.search wql
    [set_class, rules] unless rules.empty?
  end.compact
end

format do
  def duplicate_check rules
    previous_content = nil
    rules.each do |rule|
      current_content = rule.db_content.strip
      duplicate = previous_content == current_content
      changeover = previous_content && !duplicate
      previous_content = current_content
      yield rule, duplicate, changeover
    end
  end

  view :core do |args|
    render_haml args: args do
      <<-'HAML'.strip_heredoc
        = _render_rule_help args
        %table.setting-rules
          %tr
            %th Set
            %th Rule
          - card.set_classes_with_rules.each do |klass, rules|
            %tr.klass-row
              %td{class: ['setting-klass', "anchorless-#{klass.anchorless?}"]}
                = klass.anchorless? ? card_link(klass.pattern) : klass.pattern
              %td.rule-content-container
                %span.closed-content.content
                  - if klass.anchorless?
                    = subformat(rules[0])._render_closed_content
            - if !klass.anchorless?
              - duplicate_check(rules) do |rule, duplicate, changeover|
                %tr{class: ('rule-changeover' if changeover)}
                  %td.rule-anchor
                    = card_link rule.cardname.trunk_name,
                                text: rule.cardname.trunk_name.trunk_name
                  - if duplicate
                    %td
                  - else
                    %td.rule-content-container
                      %span.closed-content.content
                        = subformat(rule)._render_closed_content
      HAML
    end
  end

  view :rule_help do |_args|
    <<-HTML
      <div class="alert alert-info">
        #{process_content_object '{{+*right+*help|content}}'}
      </div>
    HTML
  end

  view :closed_content do |_args|
    render_rule_help
  end
end

format :json do
  view :export_items do |_args|
    wql = { left:  { type: Card::SetID },
            right: card.id,
            limit: 0 }
    Card.search(wql).compact.map do |rule|
      subformat(rule).render_export
    end.flatten
  end
end
