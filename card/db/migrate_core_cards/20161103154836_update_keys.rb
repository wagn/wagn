# -*- encoding : utf-8 -*-

class UpdateKeys < Card::Migration::Core
  def up
    Card.pluck(:id, :name, :key).each do |id, name, key|
      new_key = name.to_name.key
      next if new_key == key
      update_key id, key, new_key
    end
  end

  def update_key id, key, new_key
    Card.where(id: id).update_all(key: new_key)
    Card::Reference.where(referee_id: id).update_all(referee_key: new_key)
    puts "updated key '#{key}' to '#{new_key}'"
  rescue ActiveRecord::RecordNotUnique => e
    resolve_conflict id, key, new_key
  end

  def resolve_conflict id, key, new_key
    if walking_dead? key
      Card.where(id: id).delete_all
      # card wasn't reachable anyway
      # (due to rails inflection update or smartname update)
    else
      puts "key conflict: can't change #{key} to #{new_key}"
    end
  end

  def walking_dead? key
    key.include?("taxis") || key[0] == " " || key[-1] == " "
  end
end
