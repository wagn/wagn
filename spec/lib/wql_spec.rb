require File.expand_path('../spec_helper', File.dirname(__FILE__))

A_JOINEES = ["B", "C", "D", "E", "F"]

CARDS_MATCHING_TWO = ["Two","One+Two","One+Two+Three","Joe User","*plusses+*right+*content"].sort

describe Wql do
  before do
    Session.user= :joe_user
  end


  describe 'append' do
    it "should find real cards" do
      Wql.new(:name=>[:in, 'C', 'D', 'F'], :append=>'A' ).run.plot(:name).sort.should == ["C+A", "D+A", "F+A"]
    end

    it "should absolutize names" do
      Wql.new(:name=>[:in, 'C', 'D', 'F'], :append=>'_right', :context=>'B+A' ).run.plot(:name).sort.should == ["C+A", "D+A", "F+A"]
    end

    it "should find virtual cards" do
      Wql.new(:name=>[:in, 'C', 'D'], :append=>'*plus cards' ).run.plot(:name).sort.should == ["C+*plus cards", "D+*plus cards"]
    end
  end

  describe "in" do
    it "should work for content options" do
      Wql.new(:in=>['AlphaBeta', 'Theta']).run.map(&:name).sort.should == %w(A+B T)
    end

    it "should find the same thing in full syntax" do
      Wql.new(:content=>[:in,'Theta','AlphaBeta']).run.map(&:name).sort.should == %w(A+B T)
    end

    it "should work on types" do
      Wql.new(:type=>[:in,'Cardtype E', 'Cardtype F']).run.map(&:name).sort.should == %w(type-e-card type-f-card)
    end
  end

  describe "symbolization" do
    it "should handle array values" do
      query = {'plus'=>['tags',{'refer_to'=>'cookies'}]}
      Wql.new(query).query.should== {:plus=>['tags',{:refer_to=>'cookies'}]}
    end
  end


  describe "member_of/member" do
    it "member_of should find members" do
      Wql.new( :member_of => "r1" ).run.map(&:name).sort.should == %w(u1 u2 u3)
    end
    it "member should find roles" do
      Wql.new( :member => {:match=>"u1"} ).run.map(&:name).sort.should == %w(r1 r2 r3)
    end
  end


  describe "not" do
    it "should exclude cards matching not criteria" do
      Wql.new(:plus=>"A", :not=>{:plus=>"A+B"}).run.plot(:name).sort.should==%w{ B D E F }
    end
  end


  describe "edited_by/editor_of" do
    it "should find card edited by joe using subspec" do
      Wql.new(:edited_by=>{:match=>"Joe User"}, :sort=>"name").run.should == [Card["JoeLater"], Card["JoeNow"]]
    end
    it "should find card edited by Wagn Bot" do
      #this is a weak test, since it gives the name, but different sorting mechanisms in other db setups
      #was having it return *account in some cases and "A" in others
      Wql.new(:edited_by=>"Wagn Bot", :name=>'A', :return=>'name', :limit=>1).run.first.should == "A"
    end
    it "should fail gracefully if user isn't there" do
      Wql.new(:edited_by=>"Joe LUser", :sort=>"name", :limit=>1).run.should == []
    end

    it "should not give duplicate results for multiple edits" do
      Session.as(:joe_user){ c=Card["JoeNow"]; c.content="testagagin"; c.save!; c.content="test3"; c.save! }
      Wql.new(:edited_by=>"Joe User").run.map(&:name).sort.should == ["JoeLater","JoeNow"]
    end

    it "should find joe user among card's editors" do
      Wql.new(:editor_of=>'JoeLater').run.map(&:name).should == ['Joe User']
    end
  end

  describe "created_by/creator_of" do
    before do
      Session.as :joe_user do
        Card.create :name=>'Create Test', :content=>'sufficiently distinctive'
      end
    end

    it "should find Joe User as the card's creator" do
      c = Card.fetch 'Create Test'
      Wql.new(:creator_of=>'Create Test').run.first.name.should == 'Joe User'
    end

    it "should find card created by Joe User" do
      Wql.new(:created_by=>'Joe User', :eq=>'sufficiently distinctive').run.first.name.should == 'Create Test'
    end
  end

  describe "last_edited_by/last_editor_of" do
    before do
      Session.user= :joe_user
      c=Card.fetch('A'); c.content='peculicious'; c.save!
    end

    it "should find Joe User as the card's last editor" do
      Wql.new(:last_editor_of=>'A').run.first.name.should == 'Joe User'
    end

    it "should find card created by Joe User" do
      Wql.new(:last_edited_by=>'Joe User', :eq=>'peculicious').run.first.name.should == 'A'
    end
  end

  describe "keyword" do
    it "should escape nonword characters" do
      Wql.new( :match=>"two :(!").run.map(&:name).sort.should==CARDS_MATCHING_TWO
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
      Wql.new( :match=>"$keyword", :vars=>{:keyword=>"two"}).run.plot(:name).sort.should==CARDS_MATCHING_TWO
    end
  end



  describe "content equality" do
    it "should match content explicitly" do
      Wql.new( :content=>['=',"I'm number two"] ).run.plot(:name).should==["Joe User"]
    end
    it "should match via shortcut" do
      Wql.new( '='=>"I'm number two" ).run.plot(:name).should==["Joe User"]
    end
  end


  describe "links" do

    it("should handle refer_to")      { Wql.new( :refer_to=>'Z').run.plot(:name).sort.should == %w{ A B } }
    it("should handle link_to")       { Wql.new( :link_to=>'Z').run.plot(:name).should == %w{ A } }
    it("should handle include" )      { Wql.new( :include=>'Z').run.plot(:name).should == %w{ B } }
    it("should handle linked_to_by")   { Wql.new( :linked_to_by=>'A').run.plot(:name).should == %w{ Z } }
    it("should handle included_by")    { Wql.new( :included_by=>'B').run.plot(:name).should == %w{ Z } }
    it("should handle referred_to_by") { Wql.new( :referred_to_by=>'X').run.plot(:name).sort.should == %w{ A A+B T } }
  end

  describe "relative links" do
    it("should handle relative refer_to")  { Wql.new( :refer_to=>'_self', :context=>'Z').run.plot(:name).sort.should == %w{ A B } }
  end

  describe "permissions" do
    it "should not find cards not in group" do
      Session.as_bot  do
        Card.create :name=>"C+*self+*read", :type=>'Pointer', :content=>"[[R1]]"
      end
      Wql.new( :plus=>"A" ).run.plot(:name).sort.should == %w{ B D E F }
    end
  end

  describe "basics" do
    it "should be case insensitive for name" do
      Wql.new( :name=>"a" ).run.first.name.should == 'A'
    end

    it "should find plus cards" do
      Wql.new( :plus=>"A" ).run.plot(:name).sort.should == A_JOINEES
    end

    it "should find connection cards" do
      Wql.new( :part=>"A" ).run.plot(:name).sort.should == ["A+B", "A+C", "A+D", "A+E", "C+A", "D+A", "F+A"]
    end

    it "should find left connection cards" do
      Wql.new( :left=>"A" ).run.plot(:name).sort.should == ["A+B", "A+C", "A+D", "A+E"]
    end

    it "should find right connection cards" do
      Wql.new( :right=>"A" ).run.plot(:name).sort.should == ["C+A", "D+A", "F+A"]
    end

    it "should return count" do
      Card.count_by_wql( :part=>"A" ).should == 7
    end


  end

  describe "limit and offset" do
    it "should return limit" do
      Wql.new( :part=>"A", :limit=>5 ).run.size.should == 5
    end

    it "should not break if offset but no limit" do
      Wql.new( :part=>"A", :offset=>5 ).run.size.should_not == 0
    end

  end

  describe "type" do
    user_cards =  ["Joe Admin", "Joe Camel", "Joe User", "John", "No Count", "Sample User", "Sara", "u1", "u2", "u3"].sort

    it "should find cards of this type" do
      Wql.new( :type=>"_self", :context=>'User').run.plot(:name).sort.should == user_cards
    end

    it "should find User cards " do
      Wql.new( :type=>"User" ).run.plot(:name).sort.should == user_cards
    end

    it "should handle casespace variants" do
      Wql.new( :type=>"users" ).run.plot(:name).sort.should == user_cards
    end

  end

  #describe "group tagging" do
  #  it "should find frequent taggers of cardtype cards" do
  #    Wql.new( :group_tagging=>'Cardtype' ).run.map(&:name).sort().should == ["*related", "*tform"].sort()
  #  end
  #end

  describe "trash handling" do
    it "should not find cards in the trash" do
      Card["A+B"].destroy!
      Wql.new( :left=>"A" ).run.plot(:name).sort.should == ["A+C", "A+D", "A+E"]
    end
  end




  describe "order" do
    it "should sort by create" do
      Card.create! :type=>"Cardtype", :name=>"Nudetype"
      Card.create! :type=>"Nudetype", :name=>"nfirst", :content=>"a"
      Card.create! :type=>"Nudetype", :name=>"nsecond", :content=>"b"
      Card.create! :type=>"Nudetype", :name=>"nthird", :content=>"c"
      # WACK!! this doesn't seem to be consistent across fixture generations :-/
      Wql.new( :type=>"Nudetype", :sort=>"create", :dir=>"asc").run.plot(:name).should ==
        ["nfirst","nsecond","nthird"]
    end

    it "should sort by name" do
      Wql.new( :name=> %w{ in B Z A Y C X }, :sort=>"alpha", :dir=>"desc" ).run.map(&:name).should ==  %w{ Z Y X C B A }
      Wql.new( :name=> %w{ in B Z A Y C X }, :sort=>"name", :dir=>"desc"  ).run.map(&:name).should ==  %w{ Z Y X C B A }
      #Card.create! :name => 'the alphabet'
      #Wql.new( :name=>["in", "B", "C", "the alphabet"], :sort=>"name").run.map(&:name).should ==  ["the alphabet", "B", "C"]
    end

    it "should sort by content" do
      Wql.new( :name=> %w{ in Z T A }, :sort=>"content").run.plot(:name).should ==  %w{ A Z T }
    end

    it "should play nice with match" do
      Wql.new( :match=>'Z', :type=>'Basic', :sort=>"content").run.plot(:name).should ==  %w{ A B Z }
    end

    it "should sort by plus card content" do
      Session.as_bot do
        c = Card.fetch('Setting+*self+*table of contents')
        c.content = '10'
        c.save
        c = Card['Basic+*type+*table of contents']
        c.content = '3'
        c.save

        w = Wql.new( :right_plus=>'*table of contents', :sort=>{ :right=>'*table_of_contents'}, :sort_as=>'integer'  ) # FIXME: codename
        #warn "sql from new wql = #{w.sql}"
        w.run.plot(:name).should == %w{ *all *account+*right Basic+*type Config+*self Setting+*self }
      end
    end

    it "should sort by count" do
      Session.as_bot do
        w = Wql.new( :name=>[:in,'Sara','John','Joe User'], :sort=>{ :right=>'*watcher', :item=>'referred_to', :return=>'count' } )
        w.run.plot(:name).should == ['Joe User','John','Sara']
      end
    end

  #  it "should sort by update" do
  #    # do this on a restricted set so it won't change every time we add a card..
  #    Wql.new( :match=>"two", :sort=>"update", :dir=>"desc").run.plot(:name).should == ["One+Two+Three", "One+Two","Two","Joe User"]
  #    Card["Two"].update_attributes! :content=>"new bar"
  #    Wql.new( :match=>"two", :sort=>"update", :dir=>"desc").run.plot(:name).should == ["Two","One+Two+Three", "One+Two","Joe User"]
  #  end
  #

  end

  describe "params" do
    it "should merge in params as normal WQL" do
      Wql.new( :params=>{:name=>"two"}).run.first.name.should=='Two'
    end
  end


  describe "match" do
    it "should reach content and name via shortcut" do
      Wql.new( :match=>"two").run.plot(:name).sort.should==CARDS_MATCHING_TWO
    end

    it "should get only content when content is explicit" do
      Wql.new( :content=>[:match, "two"] ).run.plot(:name).sort.should==["Joe User",'*plusses+*right+*content'].sort
    end

    it "should get only name when name is explicit" do
      Wql.new( :name=>[:match, "two"] ).run.plot(:name).sort.should==["One+Two","One+Two+Three","Two"].sort
    end
  end

  describe "and" do
    it "should act as a simple passthrough" do
      Wql.new(:and=>{:match=>'two'}).run.plot(:name).sort.should==CARDS_MATCHING_TWO
    end

    it "should work within 'or'" do
      results = Wql.new(:or=>{:name=>'Z', :and=>{:left=>'A', :right=>'C'}}).run
      results.length.should == 2
      results.map(&:name).sort.should == ['A+C','Z']
    end
  end

  describe "or" do
    it "should work with :plus" do
      Wql.new(:plus=>"A", :or=>{:name=>'B', :match=>'K'}).run.plot(:name).sort.should==%w{ B }
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
      Session.user= Card::WagnBotID
      c = Card.create(:name=>'Simple Search', :type=>'Search', :content=>'{"name":"A"}')
    end

    it "should find cards returned by search of given name" do
      Wql.new(:found_by=>'Simple Search').run.first.name.should=='A'
    end
    it "should find cards returned by virtual cards" do
      Wql.new(:found_by=>'Image+*type+by name').run.plot(:name).sort.should==Card.search(:type=>'Image').plot(:name).sort
    end
    it "should play nicely with other properties and relationships" do
      Wql.new(:plus=>{:found_by=>'Simple Search'}).run.map(&:name).sort.should==Wql.new(:plus=>{:name=>'A'}).run.map(&:name).sort
    end
    it "should be able to handle _self" do
      Wql.new(:context=>'Simple Search', :left=>{:found_by=>'_self'}, :right=>'B').run.first.name.should=='A+B'
    end

  end



  #=end

  describe "relative" do
    it "should clean wql" do
      wql = Wql.new( :part=>"_self",:context=>'A' )
      wql.query[:part].should == 'A'
    end

    it "should find connection cards" do
      Wql.new( :part=>"_self", :context=>'A' ).run.plot(:name).sort.should == ["A+B", "A+C", "A+D", "A+E", "C+A", "D+A", "F+A"]
    end

    it "should be able to use parts of nonexistent cards in search" do
      Card['B+A'].should be_nil
      Wql.new( :left=>'_right', :right=>'_left', :context=>'B+A' ).run.plot(:name).should == ['A+B']
    end

    it "should find plus cards for _self" do
      Wql.new( :plus=>"_self", :context=>"A" ).run.plot(:name).sort.should == A_JOINEES
    end

    it "should find plus cards for _left" do
      # this test fails in mysql when running the full suite
      # (although not when running the individual test )
      #pending
      Wql.new( :plus=>"_left", :context=>"A+B" ).run.plot(:name).sort.should == A_JOINEES
    end

    it "should find plus cards for _right" do
      # this test fails in mysql when running the full suite
      # (although not when running the individual test )
      #pending
      Wql.new( :plus=>"_right", :context=>"C+A" ).run.plot(:name).sort.should == A_JOINEES
    end

    #I may have just fixed these.  if not please recomment and set back to pending - efm

  end


  describe "nested permissions" do
    it "are generated by default" do
      perm_count = 0
      Wql.new( { :left=>{:name=>"X"}}).sql.scan( /read_rule_id IN \([\d\,]+\)/ ) do |m|
        perm_count+=1
      end
      perm_count.should == 2
    end

    it "are not generated inside .without_nested_permissions block" do
      perm_count = 0
      Wql.without_nested_permissions do
        Wql.new( { :left=>{:name=>"X"}}).sql.scan( /read_rule_id IN \([\d\,]+\)/ ) do |m|
          perm_count+=1
        end
      end
      perm_count.should == 1
    end
  end

  #describe "return values" do
  #  # FIXME: should do other return thingies here
  #  it "returns name_content" do
  #    Wql.new( { :name => "A+B", :return => "name_content" } ).run.should == {
  #      "A+B" => "AlphaBeta"
  #    }
  #  end
  #end
end
