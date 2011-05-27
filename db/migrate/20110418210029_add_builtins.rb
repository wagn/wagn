class AddBuiltins < ActiveRecord::Migration
  def self.builtin_list
    %w{ *alerts *foot *head *navbox *now *version } << "*account links"
  end

  def self.up
    User.current_user = :wagbot
    
    Card.create! :name=>'*recent', :type=>'Search', :content=>%{{"sort":"update", "dir":"desc", "view":"change"}}
    Card.create! :name=>'*search', :type=>'Search', :content=>%{{"match":"_keyword", "sort":"relevance"}}
    Card.create! :name=>'*missing link', :type=>'Search', :content=>%{{"link_to":"_none"}}
    
    builtin_list.each do |name|
      Card.create! :name=>name
    end
  end

  def self.down
    User.current_user = :wagbot
    (builtin_list + %w{ *recent *search } << '*missing link').each do |name|
      if c = Card.fetch(name)
        c.destroy!
      end
    end    
  end
end
