format do
  view :not_found do |args|
    if update_machine_output_live?
      Card::Cache.reset_global # FIXME - wow, this kind of hard core, no?
      root.error_status = 302
      card.left.update_machine_output
      card_path card.left.machine_output_url
    else
      super args
    end
  end
  
  def update_machine_output_live?
    said = card.selected_action_id
    card.left.kind_of? Machine and                                  # must be a machine
    !card.left.locked?         and                                  # machine must not already be running    
    ( card.new_card? or !said or said == card.last_action_id )      # must want current output (won't re-output old stuff)
  end
  
end
