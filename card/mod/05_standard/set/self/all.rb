
event :admin_tasks, :on=>:update, :before=>:approve do
  if task = Env.params[:task]
    if Auth.always_ok?
      case task.to_sym
      when :clear_cache           ;  Card::Cache.reset_global
      when :repair_references     ;  Card::Reference.repair_all
      when :empty_trash           ;  Card.empty_trash
      when :delete_old_revisions  ;  Card::Action.delete_old
      when :delete_old_sessions
        if months = Env.params[:months].to_i and months > 0
          ActiveRecord::SessionStore::Session.delete_all ["updated_at < ?", months.months.ago]
        end
      end
      Env.params[:success] = Card[:stats].name
      abort :success
    else
      raise Card::PermissionDenied.new(self)
    end
  end
end
