# -*- encoding : utf-8 -*-

class AddListCards < Card::CoreMigration
  def up
    create_card! name: 'List', codename: :list,
                 type_code: :cardtype
    create_card! name: 'Listed by', codename: :listed_by,
                 type_code: :cardtype
    create_card! name: '*cached count', codename: :cached_count,
                 subcards: {
                    '+*right+*update'=>'[[Administrator]]',
                    '+*right+*create'=>'[[Administrator]]',
                    '+*right+*delete'=>'[[Administrator]]'
                  }
    create_card! name: '*cached content', codename: :cached_content,
                 subcards: {
                   '+*right+*update'=>'[[Administrator]]',
                   '+*right+*create'=>'[[Administrator]]',
                   '+*right+*delete'=>'[[Administrator]]'
                 }
  end
end
