
event :admin_tasks, :initialize, on: :update do
  if (task = Env.params[:task])
    if Auth.always_ok?
      case task.to_sym
      when :clear_cache          then Card::Cache.reset_all
      when :repair_references    then Card::Reference.repair_all
      when :empty_trash          then Card.empty_trash
      when :clear_view_cache     then Card::ViewCache.reset
      when :delete_old_revisions then Card::Action.delete_old
      when :repair_permissions   then Card.repair_all_permissions
      end
      Env.params[:success] = Card[:stats].name
      abort :success
    else
      raise Card::PermissionDenied.new(self)
    end
  end
end
