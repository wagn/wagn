format do
  # FIXME - this should be a read event (when we have read events)
  view :not_found do |args|
    if card.real? and card.left.kind_of? Machine
      card.left.update_machine_output
      self.error_status = 302
      wagn_path card.left.machine_output_path
    else
      _final_not_found args
    end
  end
end