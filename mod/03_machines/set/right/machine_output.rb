format do
  view :not_found do |args|
    if update_machine_output_live?
      root.error_status = 302      
      card.left.update_machine_output
      wagn_path card.left.machine_output_url
    else
      super args
    end
  end
  
  def update_machine_output_live?
    srid = card.selected_revision_id
    card.left.kind_of? Machine and                                  # must be a machine
    !card.left.locked?         and                                  # machine must not already be running    
    ( card.new_card? or !srid or srid == card.current_revision_id ) # must want current output (won't re-output old stuff)
  end
  
end
