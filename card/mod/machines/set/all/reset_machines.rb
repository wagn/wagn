module ClassMethods
  def reset_all_machines
    Auth.as_bot do
      Card.search(
        right: { codename: %w[in machine_cache machine_output] }
      ).each do |card|
        card.update_columns trash: true
        card.expire
      end
    end
  end
end
