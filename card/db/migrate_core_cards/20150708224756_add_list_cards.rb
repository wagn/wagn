# -*- encoding : utf-8 -*-

class AddListCards < Card::CoreMigration
  def up
    Card.create! :name=>'List', :type_code=>:cardtype, :codename=>:list
    Card.create! :name=>'Listed by', :type_code=>:cardtype, :codename=>:listed_by,
      :subcards=>{'+*right+*structure'=>'{{+type}}{{+list name}}'}
    Card.create! :name=>'*cached count', :codename=>:cached_count,
      :subcards=>{'+*right+*update'=>'[[Administrator]]', '+*right+*create'=>'[[Administrator]]', '+*right+*delete'=>'[[Administrator]]'}
    Card.create! :name=>'*cached content', :codename=>:cached_content,
      :subcards=>{'+*right+*update'=>'[[Administrator]]', '+*right+*create'=>'[[Administrator]]', '+*right+*delete'=>'[[Administrator]]'}
  end
end
