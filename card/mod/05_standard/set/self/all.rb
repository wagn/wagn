
event :admin_tasks, on: :update, before: :approve do
  if (task = Env.params[:task])
    if Auth.always_ok?
      case task.to_sym
      when :clear_cache          then Card::Cache.reset_all
      when :repair_references    then Card::Reference.repair_all
      when :empty_trash          then Card.empty_trash
      when :clear_view_cache     then Card::ViewCache.reset
      when :delete_old_revisions then Card::Action.delete_old
      when :delete_old_sessions  then Card.delete_old_sessions
      end
      Env.params[:success] = Card[:stats].name
      abort :success
    else
      raise Card::PermissionDenied.new(self)
    end
  end
end

module ClassMethods
  def delete_old_sessions
    if (months = Env.params[:months].to_i) && months > 0
      ActiveRecord::SessionStore::Session.delete_all(
        ['updated_at < ?', months.months.ago]
      )
    end
  end
end
