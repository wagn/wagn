
format :rss do
  def raw_feed_items _args
    [card]
  end
end

format :html do
  include AddHelp::HtmlFormat
end

event :update_structurees_references, :integrate,
      when: proc { |c| c.db_content_changed? || c.action == :delete } do
  return unless (statement = structuree_statement)
  Auth.as_bot do
    Card::Query.run(statement).each(&:update_references_out)
  end
end

event :reset_cache_to_use_new_structure,
      before: :update_structurees_references do
  Card::Cache.reset_hard
  Card::Cache.reset_soft
end

event :update_structurees_type, :finalize,
      changed: :type_id, when: proc { |c| c.assigns_type? } do
  update_structurees type_id: type_id
end

def structuree_names
  if (wql = structuree_statement)
    Auth.as_bot do
      Card::Query.run wql.merge(return: :name)
    end
  else
    []
  end
end

def update_structurees args
  # note that this is not smart about overriding templating rules
  # for example, if someone were to change the type of a
  # +*right+*structure rule that was overridden
  # by a +*type plus right+*structure rule, the override would not be respected.

  statement = structuree_statement
  return unless statement
  Auth.as_bot do
    statement[:return] = :id
    Card::Query.run(statement).each_slice(100) do |id_batch|
      Card.where(id: id_batch).update_all args
    end
  end
end

def structuree_statement
  set_card = trunk
  return unless set_card.type_id == SetID
  set_card.get_query
end
