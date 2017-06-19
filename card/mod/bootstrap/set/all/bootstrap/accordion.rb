format :html do
  def accordion_group list, collapse_id=card.cardname.safe_key, args={}
    accordions = ""
    index = 1
    case list
    when Array then accordions = list.join
    when String then accordions = list
    else
      list.each_pair do |title, content|
        accordions << accordion(title, content, "#{collapse_id}-#{index}")
        index += 1
      end
    end
    add_class args, "panel-group"

    wrap_with :div, class: args[:class], id: "accordion-#{collapse_id}",
                    role: "tablist", "aria-multiselectable" => "true" do
      accordions
    end
  end

  def accordion title, content, collapse_id=card.cardname.safe_key
    accordion_content =
      case content
      when Hash  then accordion_group(content, collapse_id)
      when Array then content.present? && list_group(content)
      when String then content
      end
    <<-HTML.html_safe
      <div class="panel panel-default">
        #{accordion_panel(title, accordion_content, collapse_id)}
      </div>
    HTML
  end

  def accordion_panel title, body, collapse_id, _panel_heading_link=false
    if body
      <<-HTML
        <div class="panel-heading" role="tab" id="heading-#{collapse_id}">
          <h4 class="panel-title">
            <a data-toggle="collapse" data-parent="#accordion-#{collapse_id}" \
               href="##{collapse_id}" aria-expanded="true" \
               aria-controls="#{collapse_id}">
              #{title}
            </a>
          </h4>
        </div>
        <div id="#{collapse_id}" class="panel-collapse collapse" \
               role="tabpanel" aria-labelledby="heading-#{collapse_id}">
          <div class="panel-body">
            #{body}
          </div>
        </div>
      HTML
    else
      <<-HTML
        <li class="list-group-item">
          <h4 class="panel-title">#{title}</h4>
        </li>
      HTML
    end
  end
end
