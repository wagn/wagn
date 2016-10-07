#! no set module

class ActRenderer
  def initialize format, act, args
    @act = act
    @card = format.card
    @format = format
    @args = args
    @context = args[:act_context]
  end

  def method_missing method_name, *args, &block
    if block_given?
      @format.send(method_name, *args, &block)
    else
      @format.send(method_name, *args)
    end
  end

  def respond_to_missing? method_name, _include_private=false
    @format.respond_to? method_name
  end

  def render
    act_accordion header, details, html_id
  end

  def header
    Bootstrap::Layout::BootstrapLayout.render self, {} do
      row 12 do
        col do
          tag(:h4, "pull-left") { title }
          tag(:span, "pull-right") { summary }
        end
      end
      row 12 do
        col subtitle
      end
    end
  end

  def details
    @format.render "action_#{@args[:action_view]}",
            @args.merge(action: @args[:action])
  end

  def title
    absolute_context? ? absolute_title : relative_title
  end

  def subtitle
    absolute_context? ? absolute_subtitle : relative_subtitle
  end

  def absolute_title
    accordion_expand_link(@act.card.name, html_id) + " " +
      link_to_card(@act.card, glyphicon("new-window"))
  end

  def relative_title
    link_to_card(@act.actor) + content_tag(:small, edited_ago)
  end

  def absolute_subtitle
    locals = @args.merge(act: @act, card: @card)
    template = #@format.render_haml @args.merge(act: @act, card: @card), binding do
      <<-HAML.strip_heredoc
        %small
          =
          =
          - if act.id == card.last_act.id
            %em.label.label-info Current
          - if action_view == :expanded
            - unless act.id == card.last_act.id
              = rollback_link act.actions_affecting(card)
            = show_or_hide_changes_link args
      HAML
    #end
    content = output [
                       @format.link_to_card(@act.actor),
                       edited_ago
                     ]
    content_tag :small, content.html_safe
    #::Haml::Engine.new(template).render(Object.new, locals)
  end

  def relative_subtitle
    @format.render_haml @args.merge(act: @act, card: @card) do
      <<-HAML.strip_heredoc
        .nr
          = '#' + act_seq.to_s
        %small
          = absolute_title
          - if act.id == card.last_act.id
          - if action_view == :expanded
            - unless act.id == card.last_act.id
              = rollback_link act.actions_affecting(card)
            = show_or_hide_changes_link args
      HAML
    end
  end

  def summary
    [:create, :update, :delete].map do |type|
      next unless count_types[type] > 0
      "#{@format.action_icon type} #{count_types[type]}"
    end.compact.join " | "
  end

  def count_types
    @count_types ||=
      @act.actions
        .each_with_object(Hash.new { |h, k| h[k] = 0 }) do |action, types|
        types[action.action_type] += 1
      end
  end

  def edited_ago
    "#{time_ago_in_words(@act.acted_at)} ago"
  end

  def absolute_context?
    @context == :absolute
  end

  def html_id
    "act-id-#{@act.id}"
  end

  def accordion_expand_link text, collapse_id
    <<-HTML
      <a data-toggle="collapse" data-parent="#accordion-#{collapse_id}" \
               href="##{collapse_id}" aria-expanded="true" \
               aria-controls="#{collapse_id}">
        #{text}
      </a>
    HTML
  end

  # TODO: change accordion API in bootstrap/helper.rb so that it can be used
  #   here. The problem is that here we have extra links in the title
  #   that are not supposed to expand the accordion
  def act_accordion title, content, collapse_id
    <<-HTML
    <div class="panel panel-default">
      #{act_accordion_panel(title, content, collapse_id)}
    </div>
    HTML
  end

  def act_accordion_panel title, body, collapse_id
    <<-HTML
      <div class="panel-heading" role="tab" id="heading-#{collapse_id}">
        <h4 class="panel-title">
           #{title}
        </h4>
      </div>
      <div id="#{collapse_id}" class="panel-collapse collapse" \
             role="tabpanel" aria-labelledby="heading-#{collapse_id}">
        <div class="panel-body">
          #{body}
        </div>
      </div>
    HTML
  end
end
