#! no set module

class AbsoluteActRenderer < ActRenderer
  def title
    accordion_expand_link(@act.card.name, html_id) + " " +
      link_to_card(@act.card, glyphicon("new-window")) + " " +
      link_to_card(@act.card, glyphicon("clock"), view: :history)
  end

  def subtitle
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


end
