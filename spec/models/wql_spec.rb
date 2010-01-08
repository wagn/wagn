require File.dirname(__FILE__) + '/../spec_helper'

A_JOINEES = ["B", "C", "D", "E", "F"]
      
CARDS_MATCHING_TWO = ["Two","One+Two","One+Two+Three","Joe User","*plusses+*right+*content"].sort    

#=begin
describe Wql2, 'append' do
  it "should find real cards" do
    Card.search(:name=>[:in, 'C', 'D', 'F'], :append=>'A' ).plot(:name).sort.should == ["C+A", "D+A", "F+A"]
  end

  it "should absolutize names" do
    Card.search(:name=>[:in, 'C', 'D', 'F'], :append=>'_self', :_card=>Card['A'] ).plot(:name).sort.should == ["C+A", "D+A", "F+A"]
  end

  it "should find virtual cards" do
    Card.search(:name=>[:in, 'C', 'D'], :append=>'*plus cards' ).plot(:name).sort.should == ["C+*plus cards", "D+*plus cards"]
  end
end

#=begin 
describe Wql2, "in" do          
  it "should work for content options" do
    Card.search(:in=>['AlphaBeta', 'Theta']).map(&:name).sort.should == %w(A+B T)
  end

  it "should find the same thing in full syntax" do
    Card.search(:content=>[:in,'Theta','AlphaBeta']).map(&:name).sort.should == %w(A+B T)
  end
  
  it "should work on types" do
    Card.search(:type=>[:in,'Cardtype E', 'Cardtype F']).map(&:name).sort.should == %w(type-e-card type-f-card)
  end
    
end

describe Wql2, "symbolization" do
  before {
    User.as :joe_user
  }
  it "should handle array values" do
    spec = {'plus'=>['tags',{'refer_to'=>'cookies'}]}
    Wql2::CardSpec.new(spec).spec.should== {:plus=>['tags',{:refer_to=>'cookies'}]}
  end
end


describe Wql2, "member_of/member" do
  it "member_of should find members" do
    Card.search( :member_of => "r1" ).map(&:name).sort.should == %w(u1 u2 u3)
  end
  it "member should find roles" do
    Card.search( :member => {:match=>"u1"} ).map(&:name).sort.should == %w(r1 r2 r3)
  end
end


describe Wql2, "not" do 
  before { User.as :joe_user }
  it "should exclude cards matching not criteria" do
    s = Card.search(:plus=>"A", :not=>{:plus=>"A+B"}).plot(:name).sort.should==%w{ B D E F }    
  end
end



describe Wql2, "edited_by/edited" do
  before { 
    CachedCard.bump_global_seq
  }
  it "should find card edited by joe using subspec" do
    Card.search(:edited_by=>{:match=>"Joe User"}, :sort=>"name").should == [Card["JoeLater"], Card["JoeNow"]]
  end     
  it "should find card edited by Wagn Bot" do
    Card.search(:edited_by=>"Wagn Bot", :sort=>"name", :limit=>1).should == [Card["*account"]]
  end     
  it "should fail gracefully if user isn't there" do
    Card.search(:edited_by=>"Joe LUser", :sort=>"name", :limit=>1).should == []
  end
  
  it "should not give duplicate results for multiple edits" do
    User.as(:joe_user){ c=Card["JoeNow"]; c.content="testagagin"; c.save!; c.content="test3"; c.save! }
    Card.search(:edited_by=>"Joe User", :sort=>"update", :limit=>2).map(&:name).should == ["JoeNow", "JoeLater"]
  end
  
  it "should find joe user among card's editors" do
    Card.search(:edited=>'JoeLater').map(&:name).should == ['Joe User']
  end
end



describe Card, "find_virtual" do
  before { User.as :joe_user }
  #
  it "should find: *plus parts" do
    Card.find_virtual("A+*plus parts").search(:limit=>100).plot(:name).sort.should == A_JOINEES
  end

  it "should find custom: testsearch" do
    Card::Search.create! :name=>"testsearch+*right+*virtual", 
      :extension_type=>"HardTemplate",
      :content=>'{"plus":"_self"}'  
    Card.find_virtual("A+testsearch").search(:limit=>100).plot(:name).sort.should == A_JOINEES
  end
  
end

describe Wql2, "keyword" do
  before { User.as :joe_user }
  it "should escape nonword characters" do
    Card.search( :match=>"two :(!").map(&:name).sort.should==CARDS_MATCHING_TWO
  end
end

describe Wql2, "search count" do
  before { User.as :joe_user }
  it "should count search" do
    s = Card::Search.create! :name=>"ksearch", :content=>'{"match":"_keyword"}'
    s.count("_keyword"=>"two").should==CARDS_MATCHING_TWO.length
  end
end

    
describe Wql2, "cgi_params" do
  before { User.as :joe_user }
#  it "should match content from cgi with explicit content setting" do
#    Card.search( :content=>[:match, "_keyword"], :_keyword=>"two").plot(:name).sort.should==CARDS_MATCHING_TWO
#  end

  it "should match content from cgi" do
    Card.search( :match=>"_keyword", :_keyword=>"two").plot(:name).sort.should==CARDS_MATCHING_TWO
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
    User.as :wagbot  do
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

describe Wql2, "type" do  
  before { User.as :joe_user }
  
  user_cards =  ["Joe Admin", "Joe Camel", "Joe User", "John", "No Count", "Sample User", "Sara", "u1", "u2", "u3"].sort
  
  it "should find cards of this type" do
    Card.search( :type=>"_self", :_card=>Card['User']).plot(:name).sort.should == user_cards
  end

  it "should find User cards " do
    Card.search( :type=>"User" ).plot(:name).sort.should == user_cards
  end

  it "should handle casespace variants" do
    Card.search( :type=>"users" ).plot(:name).sort.should == user_cards
  end

end

#describe Wql2, "group tagging" do
#  it "should find frequent taggers of cardtype cards" do
#    Card.search( :group_tagging=>'Cardtype' ).map(&:name).sort().should == ["*related", "*type+*default"].sort()
#  end
#end

describe Wql2, "trash handling" do   
  before { User.as :joe_user }
  
  it "should not find cards in the trash" do 
    Card["A+B"].destroy!
    Card.search( :left=>"A" ).plot(:name).sort.should == ["A+C", "A+D", "A+E"]
  end
end      




describe Wql2, "order" do
  before { User.as :joe_user }

  it "should sort by create" do  
    Card.create! :type=>"Cardtype", :name=>"Nudetype"
    Card.create! :type=>"Nudetype", :name=>"nfirst", :content=>"a"
    Card.create! :type=>"Nudetype", :name=>"nsecond", :content=>"b"
    Card.create! :type=>"Nudetype", :name=>"nthird", :content=>"c"
    # WACK!! this doesn't seem to be consistent across fixture generations :-/
    Card.search( :type=>"Nudetype", :sort=>"create", :dir=>"asc").plot(:name).should ==
      ["nfirst","nsecond","nthird"]
  end  

    it "should sort by name" do
      Card.search( :name=> %w{ in B Z A Y C X }, :sort=>"alpha", :dir=>"desc" ).plot(:name).should ==  %w{ Z Y X C B A }
      Card.search( :name=> %w{ in B Z A Y C X }, :sort=>"name", :dir=>"desc" ).plot(:name).should ==  %w{ Z Y X C B A }
    end

    it "should sort by content" do
      Card.search( :name=> %w{ in Z T A }, :sort=>"content").plot(:name).should ==  %w{ A Z T }
    end
    it "should play nice with match" do
      Card.search( :match=>'Z', :type=>'Basic', :sort=>"content").plot(:name).should ==  %w{ A B Z }
    end

#  it "should sort by update" do     
#    # do this on a restricted set so it won't change every time we add a card..
#    Card.search( :match=>"two", :sort=>"update", :dir=>"desc").plot(:name).should == ["One+Two+Three", "One+Two","Two","Joe User"]
#    Card["Two"].update_attributes! :content=>"new bar"
#    Card.search( :match=>"two", :sort=>"update", :dir=>"desc").plot(:name).should == ["Two","One+Two+Three", "One+Two","Joe User"]
#  end 
#

  
  #it "should sort by plusses" do
  #  Card.search(  :sort=>"plusses", :dir=>"desc", :limit=>6 ).plot(:name).should ==  ["*template", "A", "LewTest", "D", "C", "One"]
  #end

end





describe Wql2, "match" do 
  before { User.as :joe_user }
  
  it "should reach content and name via shortcut" do
    Card.search( :match=>"two").plot(:name).sort.should==CARDS_MATCHING_TWO
  end
  
  it "should get only content when content is explicit" do
    Card.search( :content=>[:match, "two"] ).plot(:name).sort.should==["Joe User",'*plusses+*right+*content'].sort
  end

  it "should get only name when name is explicit" do
    Card.search( :name=>[:match, "two"] ).plot(:name).sort.should==["One+Two","One+Two+Three","Two"].sort
  end
end

describe Wql2, "and" do
  it "should act as a simple passthrough" do
    Card.search(:and=>{:match=>'two'}).plot(:name).sort.should==CARDS_MATCHING_TWO
  end
end



describe Wql2, "offset" do
  it "should not break count" do
    Card.count_by_wql({:match=>'two', :offset=>1}).should==CARDS_MATCHING_TWO.length
  end
end


#=end
describe Wql2, "found_by" do
  before do
    User.as :wagbot 
    @simple_search = Card.create(:name=>'Simple Search', :type=>'Search', :content=>'{"name":"A"}')
  end 

  it "should find cards returned by search of given name" do
    Card.search(:found_by=>'Simple Search').first.name.should=='A'
  end
  it "should find cards returned by virtual cards" do
    Card.search(:found_by=>'Image+*type cards').plot(:name).sort.should==Card::Image.find(:all).plot(:name).sort
  end
  it "should play nicely with other properties and relationships" do
    Card.search(:plus=>{:found_by=>'Simple Search'}).map(&:name).sort.should==Card.search(:plus=>{:name=>'A'}).map(&:name).sort
  end
  it "should be able to handle _self" do
    Card.search(:_card=>@simple_search, :left=>{:found_by=>'_self'}, :right=>'B').first.name.should=='A+B'
  end
  
end



#=end

describe Wql2, "relative" do
  before { User.as :joe_user }

  it "should clean wql" do
    cspec = Wql2::CardSpec.new( :part=>"_self",:_card=>Card['A'] )
    cspec.spec[:part].should == 'A'
  end

  it "should find connection cards" do
    Card.search( :part=>"_self", :_card=>Card['A'] ).plot(:name).sort.should == ["A+B", "A+C", "A+D", "A+E", "C+A", "D+A", "F+A"]
  end

  it "should find plus cards for _self" do
    Card.search( :plus=>"_self", :_card=>Card["A"] ).plot(:name).sort.should == A_JOINEES
  end

  it "should find plus cards for _left" do   
    # this test fails in mysql when running the full suite 
    # (although not when running the individual test )
    #pending
    Card.search( :plus=>"_left", :_card=>Card["A+B"] ).plot(:name).sort.should == A_JOINEES
  end

  it "should find plus cards for _right" do
    # this test fails in mysql when running the full suite 
    # (although not when running the individual test )
    #pending
    Card.search( :plus=>"_right", :_card=>Card["C+A"] ).plot(:name).sort.should == A_JOINEES
  end
  
  #I may have just fixed these.  if not please recomment and set back to pending - efm
  
end


