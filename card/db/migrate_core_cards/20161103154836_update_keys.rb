# -*- encoding : utf-8 -*-

class UpdateKeys < Card::Migration::Core
  def up
    Card.pluck(:id, :name, :key).each do |id, name, key|
      new_key = name.to_name.key
      next if new_key == key
      begin
        Card.where(id: id).update_all(key: new_key)
        puts "updated key '#{key}' to '#{new_key}'"
      rescue ActiveRecord::RecordNotUnique => e
        resolve_conflict id, key, new_key
      end
    end
  end

  def resolve_conflict id, key, new_key
    if walking_dead? key
      Card::Auth.as_bot do
        Card.where(id: id).delete_all
        # card wasn't reachable anyway
        # (due to rails inflection update or smartname update)
      end
    else
      puts "key conflict: can't change #{key} to #{new_key}"
    end
  end

  def walking_dead? key
    key.include? "taxis" || key[0] == " " || key[-1] == " "
  end
end
