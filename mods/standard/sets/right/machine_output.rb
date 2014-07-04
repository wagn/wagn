format do
  view :not_found do |args|
    srid = card.selected_revision_id = nil
    if card.left.kind_of? Machine and (card.new_card? or !srid or srid == card.current_revision_id)
      # only regenerate output if it's really warranted 
      # (not when someone requests a specific old version that has been removed)
      card.left.update_machine_output   
      root.error_status = 302
      wagn_path card.left.machine_output_url
    else
      super args
    end
  end
end