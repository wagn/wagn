class SetDefaultLayout < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"Default Layout", :type=>"HTML"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<!DOCTYPE HTML>
<html>
  <head>
    {{*head}}
  </head>
  
  <body id="wagn">
    <div id="menu">
      [[/ | Home]]   [[/recent | Recent]]   {{*navbox}} {{*account links}}
    </div>
    
    <div id="primary">
      {{_main}}
    </div>
    
    <div id="secondary">
      <div id="logo">[[/ | {{*logo}}]]</div>
      {{*sidebar}}
      <div id="credit">Wheeled by [[http://www.wagn.org|Wagn]] v. {{*version}}</div>
      {{*alerts}}
    </div>
    
    {{*foot}}
  </body>
</html>
CONTENT
        card.permit('edit',Role[:admin])
        card.permit('delete',Role[:admin])
        card.save!
      end
    end
  end

  def self.down
  end
end
