# -*- encoding : utf-8 -*-

class AddSessionCardtype < Card::CoreMigration
  def up
    Card.create! :name=>'Session', :type_code=>:cardtype, :codename=>'session',
                :subcards=>{'+description'=>{:content=>'Session cards are for non-permanent content.
                  They are not stored in the database and can have different values for different users.
                  You can use a Session card to keep track of certain state of a particular user like the content
                  of shopping basket.'}}
    Card::Cache.reset_global
    Card.create! :name=>'*edit toolbar pinned', :type_code=>:session, :codename=>'edit_toolbar_pinned'
    Card.create! :name=>'*toolbar pinned', :type_code=>:session, :codename=>'toolbar_pinned'
    #Card.create! :name=>'*show cardtype', :type_code=>:session, :codename=>'show_cardtype'
  end
end
