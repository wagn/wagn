# -*- encoding : utf-8 -*-

class UpdateKeys < Card::Migration::Core
  def up
    Card.pluck(:id, :name, :key).each do |id, name, key|
      new_key = name.to_key
      next if new_key == key
      Card.where(id: id).update_all(key: new_key)
    end
  end
end
