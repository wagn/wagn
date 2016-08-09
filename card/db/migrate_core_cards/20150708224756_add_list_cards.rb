# -*- encoding : utf-8 -*-

class AddListCards < Card::CoreMigration
  def up
    create_card! name: "List", codename: :list,
                 type_code: :cardtype

    create_card! name: "Listed by", codename: :listed_by,
                 type_code: :cardtype

    create_or_update name: "*cached count",
                     codename: :cached_count,
                     rename_if_conflict: false,
                     subcards: {
                       "+*right+*update" => "[[Administrator]]",
                       "+*right+*create" => "[[Administrator]]",
                       "+*right+*delete" => "[[Administrator]]"
                     }

    create_or_update name: "*cached content",
                     codename: :cached_content,
                     rename_if_conflict: false,
                     subcards: {
                       "+*right+*update" => "[[Administrator]]",
                       "+*right+*create" => "[[Administrator]]",
                       "+*right+*delete" => "[[Administrator]]"
                     }
  end
end
