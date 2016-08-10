module ClassMethods
  def reset_all_machines
    Auth.as_bot do
      Card.search(right: { codename: 'machine_cache' }).each do |card|
        card.update_columns trash: true
        card.expire
      end
      Card.search(right: { codename: 'machine_output' }).each do |card|
        card.update_columns trash: true
        card.expire
      end
    end
  end
end