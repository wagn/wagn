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
      # example:
      # "Matthias Taxes" can be in the database with two keys:
      # "matthia_taxis" and "matthia_tax".
      # Their keys will both be updated to "matthias_tax".
      # "matthia_taxis" is a walking dead since the last rails inflection
      # update (it's in the db but you can only get to via its id; all requests via
      # name find the other one). If we update the walking dead
      # "matthia_taxis" first to "matthias_tax" we want to replace it with
      # the living "matthia_tax".
      # The living card is the one that has been updated more recently.
      longer_untouched = [Card.find(id), Card.find_by_key(new_key)]
                           .min { |a, b| a.updated_at <=> b.updated_at}
      Card.where(id: longer_untouched).delete_all
      update_key id, key, new_key if longer_untouched != id
    end
  end

  def walking_dead? key
    key.include?("taxis") || key[0] == " " || key[-1] == " "
  end
end
