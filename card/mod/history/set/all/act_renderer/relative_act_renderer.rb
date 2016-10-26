#! no set module

class RelativeActRenderer < ActRenderer
  def title
    "<span class=\"nr\">##{@args[:act_seq]}</span>" +
      accordion_expand_link(@act.actor.name, html_id) +
      " " +
      content_tag(:small, edited_ago)
  end

  def subtitle
    expanded = ""
    if @args[:action_view] == :expanded
      expanded += rollback_link @act.actions_affecting(@card) unless @act.id == @card.last_act.id
      expanded += show_or_hide_changes_link
    end
    <<-HTML
      <small>
        act on #{absolute_title}
    #{expanded}
      </small>
    HTML
    # @format.render_haml @args.merge(act: @act, card: @card) do
    #   <<-HAML.strip_heredoc
    #     .nr
    #       = '#' + act_seq.to_s
    #     %small
    #       = absolute_title
    #       - if action_view == :expanded
    #         - unless act.id == card.last_act.id
    #           = rollback_link act.actions_affecting(card)
    #         = show_or_hide_changes_link args
    #   HAML
  end
end
