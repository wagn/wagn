# -*- encoding : utf-8 -*-

class AddSolidCacheCards < Card::Migration
  def up
    ensure_card name: "*solid cache",
                codename: "solid_cache"
    ensure_card name: "*solid cache+*right+*read",
                content: "_left"
  end
end
