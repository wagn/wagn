
event :admin_tasks, :on=>:update, :before=>:approve do
  if task = Env.params[:task]
    case task.to_sym
    when :clear_cache           ;  Wagn::Cache.reset_global
    when :repair_references     ;  Card::Reference.repair_all
    when :empty_trash           ;  Card.empty_trash
    when :delete_old_revisions  ;  Card::Revision.delete_old
    end
    Env.params[:success] = Card[:stats].name
    abort :success
  end
end
