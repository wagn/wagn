def followable?
  false
end

def history?
  false
end

format do
  view :not_found do |args|
    if update_machine_output_live?
      Card::Cache.reset_all # FIXME: wow, this is overkill, no?
      root.error_status = 302
      card.left.update_machine_output
      card_path card.left.machine_output_url
    else
      super args
    end
  end

  def update_machine_output_live?
    case
    when !card.left.is_a?(Machine) then false # must be a machine
    when card.left.locked?         then false # machine must not be running
    when card.new_card?            then true  # always update if new
    else
      # must want current output (won't re-output old stuff)
      (selected_id = card.selected_action_id) &&
        selected_id == card.last_action_id
    end
  end
end
