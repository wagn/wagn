format :html do
  def default_act_args args
    act = (args[:act]  ||= Act.find(params["act_id"]))
    args[:act_seq]     ||= params["act_seq"]
    args[:hide_diff]   ||= hide_diff?
    args[:slot_class]  ||= "revision-#{act.id} history-slot list-group-item"
    args[:action_view] ||= action_view
    args[:actions]     ||= action_list args
    act_context args
  end


  view :act do |args|
    ActRenderer.new(self, args[:act], args).render

    # wrap(args) do
    #   render_haml args.merge(card: card, args: args) do
    #     <<-HAML.strip_heredoc
    #       .act{style: "clear:both;"}
    #         - show_header = act_context == :absolute ? :show : :hide
    #         = optional_render :act_header, args, show_header
    #         .head
    #           = render :act_metadata, args
    #         .toggle
    #           = fold_or_unfold_link args
    #         .action-container
    #           - actions.each do |action|
    #             = render "action_#{args[:action_view]}", args.merge(action: action)
    #     HAML
    #   end
    # end
  end

  def action_icon action_type
    icon = case action_type
           when :create then "plus"
           when :update then "pencil"
           when :delete then "trash"
           end
    glyphicon icon
  end

  private

  def act_context args
    args[:act_context] =
      (args[:act_context] || params["act_context"] || :relative).to_sym
  end
end