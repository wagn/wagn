# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

A_JOINEES = ["B", "C", "D", "E", "F"]

CARDS_MATCHING_TWO = ["Two","One+Two","One+Two+Three","Joe User"].sort

describe Card::Query do

  describe 'append' do
    it "should find real cards" do
      Card::Query.new(:name=>[:in, 'C', 'D', 'F'], :append=>'A' ).run.map(&:name).sort.should == ["C+A", "D+A", "F+A"]
    end

    it "should absolutize names" do
      Card::Query.new(:name=>[:in, 'C', 'D', 'F'], :append=>'_right', :context=>'B+A' ).run.map(&:name).sort.should == ["C+A", "D+A", "F+A"]
    end

    it "should find virtual cards" do
      Card::Query.new(:name=>[:in, 'C', 'D'], :append=>'*plus cards' ).run.map(&:name).sort.should == ["C+*plus cards", "D+*plus cards"]
    end
  end

  describe "in" do
    it "should work for content options" do
      Card::Query.new(:in=>['AlphaBeta', 'Theta']).run.map(&:name).sort.should == %w(A+B T)
    end

    it "should find the same thing in full syntax" do
      Card::Query.new(:content=>[:in,'Theta','AlphaBeta']).run.map(&:name).sort.should == %w(A+B T)
    end

    it "should work on types" do
      Card::Query.new(:type=>[:in,'Cardtype E', 'Cardtype F']).run.map(&:name).sort.should == %w(type-e-card type-f-card)
    end
  end

  describe "symbolization" do
    it "should handle array values" do
      query = {'plus'=>['tags',{'refer_to'=>'cookies'}]}
      Card::Query.new(query).query.should== {:plus=>['tags',{:refer_to=>'cookies'}]}
    end
  end





  describe "member_of/member" do
    it "member_of should find members" do
      Card::Query.new( :member_of => "r1" ).run.map(&:name).sort.should == %w(u1 u2 u3)
    end
    it "member should find roles" do
      Card::Query.new( :member => {:match=>"u1"} ).run.map(&:name).sort.should == %w(r1 r2 r3)
    end
  end


  describe "not" do
    it "should exclude cards matching not criteria" do
      Card::Query.new(:plus=>"A", :not=>{:plus=>"A+B"}).run.map(&:name).sort.should==%w{ B D E F }
    end
  end
  
  
  describe "multiple values" do
    it "should handle multiple values for relational keys" do
      Card::Query.new( :member_of=>[:all, {:name=>'r1'}, {:key=>'r2'} ], :return=>:name).run.sort.should == %w{ u1 u2 }
      Card::Query.new( :member_of=>[      {:name=>'r1'}, {:key=>'r2'} ], :return=>:name).run.sort.should == %w{ u1 u2 }
      Card::Query.new( :member_of=>[:any, {:name=>'r1'}, {:key=>'r2'} ], :return=>:name).run.sort.should == %w{ u1 u2 u3 }      
    end
    
    it "should handle multiple values for plus_relational keys" do
      Card::Query.new( :right_plus=>[ :all, 'e', 'c' ], :return=>:name ).run.sort.should == %w{ A } #explicit conjunction
      Card::Query.new( :right_plus=>[ ['e',{}],  'c' ], :return=>:name ).run.sort.should == %w{ A } # first element is array
      Card::Query.new( :right_plus=>[ 'e', 'c'       ], :return=>:name ).run.sort.should == []      # NOT interpreted as multi-value
    end

    it "should handle multiple values for plus_relational keys" do
      Card::Query.new( :refer_to=>[ :and, 'a', 'b' ], :return=>:name ).run.sort.should == %w{ Y } 
      Card::Query.new( :refer_to=>[       'a', 'T' ], :return=>:name ).run.sort.should == %w{ X Y }
      Card::Query.new( :refer_to=>[ :or,  'b', 'z' ], :return=>:name ).run.sort.should == %w{ A B Y}
    end
        
  end


  describe "edited_by/editor_of" do
    it "should find card edited by joe using subspec" do
      Card::Query.new(:edited_by=>{:match=>"Joe User"}, :sort=>"name").run.should == [Card["JoeLater"], Card["JoeNow"]]
    end
    it "should find card edited by Wagn Bot" do
      #this is a weak test, since it gives the name, but different sorting mechanisms in other db setups
      #was having it return *account in some cases and "A" in others
      Card::Query.new(:edited_by=>"Wagn Bot", :name=>'A', :return=>'name', :limit=>1).run.first.should == "A"
    end
    it "should fail gracefully if user isn't there" do
      Card::Query.new(:edited_by=>"Joe LUser", :sort=>"name", :limit=>1).run.should == []
    end

    it "should not give duplicate results for multiple edits" do
      c=Card["JoeNow"]
      c.content="testagagin"
      c.save
      c.content="test3"
      c.save!
      Card::Query.new(:edited_by=>"Joe User").run.map(&:name).sort.should == ["JoeLater","JoeNow"]
    end

    it "should find joe user among card's editors" do
      Card::Query.new(:editor_of=>'JoeLater').run.map(&:name).should == ['Joe User']
    end
  end

  describe "created_by/creator_of" do
    before do
      Card.create :name=>'Create Test', :content=>'sufficiently distinctive'
    end

    it "should find Joe User as the card's creator" do
      c = Card.fetch 'Create Test'
      Card::Query.new(:creator_of=>'Create Test').run.first.name.should == 'Joe User'
    end

    it "should find card created by Joe User" do
      Card::Query.new(:created_by=>'Joe User', :eq=>'sufficiently distinctive').run.first.name.should == 'Create Test'
    end
  end

  describe "last_edited_by/last_editor_of" do
    before do
      c=Card.fetch('A')
      c.content='peculicious'
      c.save!
    end

    it "should find Joe User as the card's last editor" do
      Card::Query.new(:last_editor_of=>'A').run.first.name.should == 'Joe User'
    end

    it "should find card created by Joe User" do
      Card::Query.new(:last_edited_by=>'Joe User', :eq=>'peculicious').run.first.name.should == 'A'
    end
  end

  describe "keyword" do
    it "should escape nonword characters" do
      Card::Query.new( :match=>"two :(!").run.map(&:name).sort.should==CARDS_MATCHING_TWO
    end
  end

  describe "search count" do
    it "should count search" do
      s = Card.create! :name=>"ksearch", :type=>'Search', :content=>'{"match":"$keyword"}'
      s.count(:vars=>{:keyword=>"two"}).should==CARDS_MATCHING_TWO.length
    end
  end


  describe "cgi_params" do
    it "should match content from cgi" do
      Card::Query.new( :match=>"$keyword", :vars=>{:keyword=>"two"}).run.map(&:name).sort.should==CARDS_MATCHING_TWO
    end
  end



  describe "content equality" do
    it "should match content explicitly" do
      Card::Query.new( :content=>['=',"I'm number two"] ).run.map(&:name).should==["Joe User"]
    end
    it "should match via shortcut" do
      Card::Query.new( '='=>"I'm number two" ).run.map(&:name).should==["Joe User"]
    end
  end


  describe "links" do

    it("should handle refer_to")      { Card::Query.new( :refer_to=>'Z').run.map(&:name).sort.should == %w{ A B } }
    it("should handle link_to")       { Card::Query.new( :link_to=>'Z').run.map(&:name).should == %w{ A } }
    it("should handle include" )      { Card::Query.new( :include=>'Z').run.map(&:name).should == %w{ B } }
    it("should handle linked_to_by")   { Card::Query.new( :linked_to_by=>'A').run.map(&:name).should == %w{ Z } }
    it("should handle included_by")    { Card::Query.new( :included_by=>'B').run.map(&:name).should == %w{ Z } }
    it("should handle referred_to_by") { Card::Query.new( :referred_to_by=>'X').run.map(&:name).sort.should == %w{ A A+B T } }
  end

  describe "relative links" do
    it("should handle relative refer_to")  { Card::Query.new( :refer_to=>'_self', :context=>'Z').run.map(&:name).sort.should == %w{ A B } }
  end

  describe "permissions" do
    it "should not find cards not in group" do
      Account.as_bot  do
        Card.create :name=>"C+*self+*read", :type=>'Pointer', :content=>"[[R1]]"
      end
      Card::Query.new( :plus=>"A" ).run.map(&:name).sort.should == %w{ B D E F }
    end
  end

  describe "basics" do
    it "should be case insensitive for name" do
      Card::Query.new( :name=>"a" ).run.first.name.should == 'A'
    end

    it "should find plus cards" do
      Card::Query.new( :plus=>"A" ).run.map(&:name).sort.should == A_JOINEES
    end

    it "should find connection cards" do
      Card::Query.new( :part=>"A" ).run.map(&:name).sort.should == ["A+B", "A+C", "A+D", "A+E", "C+A", "D+A", "F+A"]
    end

    it "should find left connection cards" do
      Card::Query.new( :left=>"A" ).run.map(&:name).sort.should == ["A+B", "A+C", "A+D", "A+E"]
    end

    it "should find right connection cards" do
      Card::Query.new( :right=>"A" ).run.map(&:name).sort.should == ["C+A", "D+A", "F+A"]
    end

    it "should return count" do
      Card.count_by_wql( :part=>"A" ).should == 7
    end


  end

  describe "limit and offset" do
    it "should return limit" do
      Card::Query.new( :part=>"A", :limit=>5 ).run.size.should == 5
    end

    it "should not break if offset but no limit" do
      Card::Query.new( :part=>"A", :offset=>5 ).run.size.should_not == 0
    end

  end

  describe "type" do
    user_cards =  ["Joe Admin", "Joe Camel", "Joe User", "John", "No Count", "Sample User", "Sara", "u1", "u2", "u3"].sort

    it "should find cards of this type" do
      Card::Query.new( :type=>"_self", :context=>'User').run.map(&:name).sort.should == user_cards
    end

    it "should find User cards " do
      Card::Query.new( :type=>"User" ).run.map(&:name).sort.should == user_cards
    end

    it "should handle casespace variants" do
      Card::Query.new( :type=>"users" ).run.map(&:name).sort.should == user_cards
    end

  end


  describe "trash handling" do
    it "should not find cards in the trash" do
      Card["A+B"].delete!
      Card::Query.new( :left=>"A" ).run.map(&:name).sort.should == ["A+C", "A+D", "A+E"]
    end
  end




  describe "order" do
    it "should sort by create" do
      Card.create! :type=>"Cardtype", :name=>"Nudetype"
      Card.create! :type=>"Nudetype", :name=>"nfirst", :content=>"a"
      Card.create! :type=>"Nudetype", :name=>"nsecond", :content=>"b"
      Card.create! :type=>"Nudetype", :name=>"nthird", :content=>"c"
      # WACK!! this doesn't seem to be consistent across fixture generations :-/
      Card::Query.new( :type=>"Nudetype", :sort=>"create", :dir=>"asc").run.map(&:name).should ==
        ["nfirst","nsecond","nthird"]
    end

    it "should sort by name" do
      Card::Query.new( :name=> %w{ in B Z A Y C X }, :sort=>"alpha", :dir=>"desc" ).run.map(&:name).should ==  %w{ Z Y X C B A }
      Card::Query.new( :name=> %w{ in B Z A Y C X }, :sort=>"name", :dir=>"desc"  ).run.map(&:name).should ==  %w{ Z Y X C B A }
      #Card.create! :name => 'the alphabet'
      #Card::Query.new( :name=>["in", "B", "C", "the alphabet"], :sort=>"name").run.map(&:name).should ==  ["the alphabet", "B", "C"]
    end

    it "should sort by content" do
      Card::Query.new( :name=> %w{ in Z T A }, :sort=>"content").run.map(&:name).should ==  %w{ A Z T }
    end

    it "should play nice with match" do
      Card::Query.new( :match=>'Z', :type=>'Basic', :sort=>"content").run.map(&:name).should ==  %w{ A B Z }
    end

    it "should sort by plus card content" do
      Account.as_bot do
        c = Card.fetch('Setting+*self+*table of contents')
        c.content = '10'
        c.save
        c = Card['Basic+*type+*table of contents']
        c.content = '3'
        c.save

        w = Card::Query.new( :right_plus=>'*table of contents', :sort=>{ :right=>'*table_of_contents'}, :sort_as=>'integer'  ) # FIXME: codename
        #warn "sql from new wql = #{w.sql}"
        w.run.map(&:name).should == %w{ *all *account+*right Basic+*type Config+*self Setting+*self }
      end
    end

    it "should sort by count" do
      Account.as_bot do
        w = Card::Query.new( :name=>[:in,'Sara','John','Joe User'], :sort=>{ :right=>'*watcher', :item=>'referred_to', :return=>'count' } )
        w.run.map(&:name).should == ['Joe User','John','Sara']
      end
    end

  #  it "should sort by update" do
  #    # do this on a restricted set so it won't change every time we add a card..
  #    Card::Query.new( :match=>"two", :sort=>"update", :dir=>"desc").run.map(&:name).should == ["One+Two+Three", "One+Two","Two","Joe User"]
  #    Card["Two"].update_attributes! :content=>"new bar"
  #    Card::Query.new( :match=>"two", :sort=>"update", :dir=>"desc").run.map(&:name).should == ["Two","One+Two+Three", "One+Two","Joe User"]
  #  end
  #

  end

  describe "params" do
    it "should merge in params as normal WQL" do
      Card::Query.new( :params=>{:name=>"two"}).run.first.name.should=='Two'
    end
  end


  describe "match" do
    it "should reach content and name via shortcut" do
      Card::Query.new( :match=>"two").run.map(&:name).sort.should==CARDS_MATCHING_TWO
    end

    it "should get only content when content is explicit" do
      Card::Query.new( :content=>[:match, "two"] ).run.map(&:name).sort.should==["Joe User"]
    end

    it "should get only name when name is explicit" do
      Card::Query.new( :name=>[:match, "two"] ).run.map(&:name).sort.should==["One+Two","One+Two+Three","Two"].sort
    end
  end

  describe "and" do
    it "should act as a simple passthrough" do
      Card::Query.new(:and=>{:match=>'two'}).run.map(&:name).sort.should==CARDS_MATCHING_TWO
    end

    it "should work within 'or'" do
      results = Card::Query.new(:or=>{:name=>'Z', :and=>{:left=>'A', :right=>'C'}}).run
      results.length.should == 2
      results.map(&:name).sort.should == ['A+C','Z']
    end
  end

  describe "or" do
    it "should work with :plus" do
      Card::Query.new(:plus=>"A", :or=>{:name=>'B', :match=>'K'}).run.map(&:name).sort.should==%w{ B }
    end
  end

  describe "offset" do
    it "should not break count" do
      Card.count_by_wql({:match=>'two', :offset=>1}).should==CARDS_MATCHING_TWO.length
    end
  end


  #=end
  describe "found_by" do
    before do
      Account.current_id = Card::WagnBotID
      c = Card.create(:name=>'Simple Search', :type=>'Search', :content=>'{"name":"A"}')
    end

    it "should find cards returned by search of given name" do
      Card::Query.new(:found_by=>'Simple Search').run.first.name.should=='A'
    end
    it "should find cards returned by virtual cards" do
      Card::Query.new(:found_by=>'Image+*type+by name').run.map(&:name).sort.should==Card.search(:type=>'Image').map(&:name).sort
    end
    it "should play nicely with other properties and relationships" do
      Card::Query.new(:plus=>{:found_by=>'Simple Search'}).run.map(&:name).sort.should==Card::Query.new(:plus=>{:name=>'A'}).run.map(&:name).sort
    end
    it "should be able to handle _self" do
      Card::Query.new(:context=>'Simple Search', :left=>{:found_by=>'_self'}, :right=>'B').run.first.name.should=='A+B'
    end

  end



  #=end

  describe "relative" do
    it "should clean wql" do
      wql = Card::Query.new( :part=>"_self",:context=>'A' )
      wql.query[:part].should == 'A'
    end

    it "should find connection cards" do
      Card::Query.new( :part=>"_self", :context=>'A' ).run.map(&:name).sort.should == ["A+B", "A+C", "A+D", "A+E", "C+A", "D+A", "F+A"]
    end

    it "should be able to use parts of nonexistent cards in search" do
      Card['B+A'].should be_nil
      Card::Query.new( :left=>'_right', :right=>'_left', :context=>'B+A' ).run.map(&:name).should == ['A+B']
    end

    it "should find plus cards for _self" do
      Card::Query.new( :plus=>"_self", :context=>"A" ).run.map(&:name).sort.should == A_JOINEES
    end

    it "should find plus cards for _left" do
      Card::Query.new( :plus=>"_left", :context=>"A+B" ).run.map(&:name).sort.should == A_JOINEES
    end

    it "should find plus cards for _right" do
      Card::Query.new( :plus=>"_right", :context=>"C+A" ).run.map(&:name).sort.should == A_JOINEES
    end

  end


  describe "nested permissions" do
    it "are generated by default" do
      perm_count = 0
      Card::Query.new( { :left=>{:name=>"X"}}).sql.scan( /read_rule_id IN \([\d\,]+\)/ ) do |m|
        perm_count+=1
      end
      perm_count.should == 2
    end

#    it "are not generated inside .without_nested_permissions block" do
#      perm_count = 0
#      Card::Query.without_nested_permissions do
#        Card::Query.new( { :left=>{:name=>"X"}}).sql.scan( /read_rule_id IN \([\d\,]+\)/ ) do |m|
#          perm_count+=1
#        end
#      end
#      perm_count.should == 1
#    end
  end

  #describe "return values" do
  #  # FIXME: should do other return thingies here
  #  it "returns name_content" do
  #    Card::Query.new( { :name => "A+B", :return => "name_content" } ).run.should == {
  #      "A+B" => "AlphaBeta"
  #    }
  #  end
  #end
end
