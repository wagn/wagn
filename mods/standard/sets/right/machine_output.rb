format do
  view :not_found do |args|
    if card.left.kind_of? Machine
      #card.left.refresh.update_machine_output   #FIXME problems with cache; without refresh this produces a loop 
                                                #      (it creates a new file but returns the url to a "newer" version that doesn't exist )
      Wagn::Cache.reset_global
      card.left.update_machine_output
      self.error_status = 302
      wagn_path card.left.machine_output_url
    else
      super args
    end
  end
end
