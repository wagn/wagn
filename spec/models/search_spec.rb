require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../test/helpers/wagn_test_helper'

include WagnTestHelper


A_JOINEES = ["B", "C", "D", "E", "F"]
      
CARDS_MATCHING_TWO = ["Two","One+Two","One+Two+Three","Joe User"].sort    



describe Wql2, "edited_by" do
  before { 
    User.as(:joe_user) {  Card.create!( :name=>"JoeLater", :content=>"test") }
    User.as(:joe_user) {  Card.create!( :name=>"JoeNow", :content=>"test") }
    User.as(:admin) {  Card.create!(:name=>"AdminNow", :content=>"test") }
  }
  it "should find card edited by joe" do
    Card.search(:edited_by=>"Joe User", :sort=>"update", :limit=>1).should == [Card["JoeNow"]]
  end     
  it "should find card edited by joe" do
    Card.search(:edited_by=>"Admin", :sort=>"update", :limit=>1).should == [Card["AdminNow"]]
  end     
  it "should fail gracefully if user isn't there" do
    Card.search(:edited_by=>"Joe LUser", :sort=>"update", :limit=>1).should == []
  end
  
  it "should not give duplicate results for multiple edits" do
    User.as(:joe_user){ c=Card["JoeNow"]; c.content="testagagin"; c.save!; c.content="test3"; c.save! }
    Card.search(:edited_by=>"Joe User", :sort=>"update", :limit=>2).map(&:name).should == ["JoeNow", "JoeLater"]
  end
end

=begin

describe Card, "find_phantom" do
  before { User.as :joe_user }

  it "should find: *plus parts" do
    Card.find_phantom("A+*plus parts").search(:limit=>100).plot(:name).sort.should == A_JOINEES
  end

  it "should find custom: testsearch" do
    Card::Search.create! :name=>"testsearch+*rform", 
      :extension_type=>"HardTemplate",
      :content=>'{"plus":"_self"}'  
    Card.find_phantom("A+testsearch").search(:limit=>100).plot(:name).sort.should == A_JOINEES
  end
end

   
describe Wql2, "not" do 
  before { User.as :joe_user }
  it "should exclude cards matching not criteria" do
    s = Card.search(:plus=>"A", :not=>{:plus=>"A+B"}).plot(:name).sort.should==%w{ B D E F }    
  end
end

describe Wql2, "order" do
  before { User.as :joe_user }

  
  it "should sort by create" do  
    given_cards(
      { "Cardtype:Nudetype" => ""},
      { "Nudetype:nfirst" => "a"},
      { "Nudetype:nsecond" => "b"},
      { "Nudetype:nthird"=> "c" }
    )
    # WACK!! this doesn't seem to be consistent across fixture generations :-/
    Card.search( :type=>"Nudetype", :sort=>"create", :dir=>"asc").plot(:name).should ==
      ["nfirst","nsecond","nthird"]
  end  

#  it "should sort by update" do     
#    # do this on a restricted set so it won't change every time we add a card..
#    Card.search( :match=>"two", :sort=>"update", :dir=>"desc").plot(:name).should == ["One+Two+Three", "One+Two","Two","Joe User"]
#    Card["Two"].update_attributes! :content=>"new bar"
#    Card.search( :match=>"two", :sort=>"update", :dir=>"desc").plot(:name).should == ["Two","One+Two+Three", "One+Two","Joe User"]
#  end 
#
#  it "should sort by alhpa" do
#    Card.search( :sort=>"alpha", :dir=>"desc", :limit=>6 ).plot(:name).should ==  ["Z", "Y", "X", "Wagn", "UserForm+*template", "UserForm"]
#  end
  
  #it "should sort by plusses" do
  #  Card.search(  :sort=>"plusses", :dir=>"desc", :limit=>6 ).plot(:name).should ==  ["*template", "A", "LewTest", "D", "C", "One"]
  #end

end
    

describe Wql2, "keyword" do
  before { User.as :joe_user }
  it "should escape nonword characters" do
    Card.search( :match=>"two :(!").map(&:name).sort.should==["Joe User","One+Two","One+Two+Three","Two"]
  end
end

describe Wql2, "search count" do
  before { User.as :joe_user }
  it "should cound search" do
    s = Card::Search.create! :name=>"ksearch", :content=>'{"match":"_keyword"}'
    s.count("_keyword"=>"two").should==CARDS_MATCHING_TWO.length
  end
end

    
describe Wql2, "cgi_params" do
  before { User.as :joe_user }
  it "should match content from cgi" do
    Card.search( :content=>[:match, "_keyword"], :_keyword=>"two").plot(:name).sort.should==CARDS_MATCHING_TWO
  end

  it "should match content from cgi" do
    Card.search( :match=>"_keyword", :_keyword=>"two").plot(:name).sort.should==CARDS_MATCHING_TWO
  end
end



describe Wql2, "fulltext" do 
  before { User.as :joe_user }
  it "should match content explicity" do
    Card.search( :content=>[:match, "two"] ).plot(:name).sort.should==CARDS_MATCHING_TWO
  end
  it "should match via shortcut" do
    Card.search( :match=>"two").plot(:name).sort.should==CARDS_MATCHING_TWO
  end
end

describe Wql2, "content equality" do 
  before { User.as :joe_user }
  it "should match content explicitly" do
    Card.search( :content=>['=',"I'm number two"] ).plot(:name).should==["Joe User"]
  end
  it "should match via shortcut" do
    Card.search( '='=>"I'm number two" ).plot(:name).should==["Joe User"]
  end
end


describe Wql2, "links" do     
  before do
    User.as :joe_user
  end

  it("should handle refer_to")      { Card.search( :refer_to=>'Z').plot(:name).sort.should == %w{ A B } }
  it("should handle link_to")       { Card.search( :link_to=>'Z').plot(:name).should == %w{ A } }
  it("should handle include" )      { Card.search( :include=>'Z').plot(:name).should == %w{ B } }
  it("should handle linked_to_by")   { Card.search( :linked_to_by=>'A').plot(:name).should == %w{ Z } }
  it("should handle included_by")    { Card.search( :included_by=>'B').plot(:name).should == %w{ Z } }
  it("should handle referred_to_by") { Card.search( :referred_to_by=>'X').plot(:name).sort.should == %w{ A A+B T } }
end
  
describe Wql2, "relative links" do
  before { User.as :joe_user }
  it("should handle relative refer_to")  { Card.search( :refer_to=>'_self', :_card=>Card['Z']).plot(:name).sort.should == %w{ A B } }
end


describe Wql2, "permissions" do
  it "should not find cards not in group" do
    User.as :admin do
      c = Card['C']
      c.permit(:read, Role['r1'])
      c.save!
    end
    User.as :joe_user do
      Card.search( :plus=>"A" ).plot(:name).sort.should == %w{ B D E F }
    end
  end
end

describe Wql2, "basics" do
  before do
    User.as :joe_user
  end
  
  it "should find plus cards" do
    Card.search( :plus=>"A" ).plot(:name).sort.should == A_JOINEES
  end
  
  it "should find connection cards" do
    Card.search( :part=>"A" ).plot(:name).sort.should == ["A+B", "A+C", "A+D", "A+E", "C+A", "D+A", "F+A"]
  end    
  
  it "should find left connection cards" do
    Card.search( :left=>"A" ).plot(:name).sort.should == ["A+B", "A+C", "A+D", "A+E"]
  end

  it "should find right connection cards" do
    Card.search( :right=>"A" ).plot(:name).sort.should == ["C+A", "D+A", "F+A"]
  end

  
  it "should return count" do
    Card.count_by_wql( :part=>"A" ).should == 7
  end

  it "should return count" do
    Card.search( :part=>"A", :limit=>5 ).size.should == 5
  end

end



describe Wql2, "relative" do
  before { User.as :joe_user }

  it "should find connection cards" do
    Card.search( :part=>"_self", :_card=>Card['A'] ).plot(:name).sort.should == ["A+B", "A+C", "A+D", "A+E", "C+A", "D+A", "F+A"]
  end

  it "should find plus cards for _self" do
    Card.search( :plus=>"_self", :_card=>Card["A"] ).plot(:name).sort.should == A_JOINEES
  end

  it "should find plus cards for _left" do
    Card.search( :plus=>"_left", :_card=>Card["A+B"] ).plot(:name).sort.should == A_JOINEES
  end

  it "should find plus cards for _right" do
    Card.search( :plus=>"_right", :_card=>Card["C+A"] ).plot(:name).sort.should == A_JOINEES
  end
end



describe Wql2, "type" do  
  before { User.as :joe_user }
  it "should find cards of this type" do
    Card.search( :type=>"_self", :_card=>Card['User']).plot(:name).sort.should == ["Joe User","No Count","Sample User","Wagn Bot","Admin","Anonymous"].sort
  end

  it "should find cards of this type" do
    Card.search( :type=>"User" ).plot(:name).sort.should == ["Joe User","No Count","Sample User","Wagn Bot","Admin","Anonymous"].sort
  end

end


describe Wql2, "group tagging" do
  it "should find frequent taggers of basic cards" do
    Card.search( :group_tagging=>'Basic' ).map(&:name).sort().should ==   ["*rform", "A", "C", "B", "D", "E", "Five", "One", "Three", "Two"].sort()
  end
end

describe Wql2, "trash handling" do   
  before { User.as :joe_user }
  
  it "should not find cards in the trash" do 
    Card["A+B"].destroy!
    Card.search( :left=>"A" ).plot(:name).sort.should == ["A+C", "A+D", "A+E"]
  end
end      


=end



