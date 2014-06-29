
format do
  view :not_found do |args|
    if card.left.kind_of? Machine
      card.left.update_machine_output
      root.error_status = 302
      wagn_path card.left.machine_output_card.attach.url(:default, :timestamp => false)  # to get rid of additional number in url
    else
      super args
    end
  end
end