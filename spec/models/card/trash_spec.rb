require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Card, "deleted card" do
  before do
    Account.as_bot do
      @c = Card['A']
      @c.destroy!
    end
  end
  it "should be in the trash" do
    @c.trash.should be_true
  end
  it "should come out of the trash when a plus card is created" do
    Account.as_bot do
      Card.create(:name=>'A+*acct')
      c = Card.fetch 'A', :new=>{}
      c.trash.should be_false
    end
  end
end

describe Card, "in trash" do
  it "should be retrieved by fetch or create" do
    Account.as :joe_user do
      Card.create(:name=>"Betty").destroy
      card = Card.fetch "Betty", :new => {}
      card.save if card.new_card?

      Card["Betty"].should be_instance_of(Card)
    end
  end
end

# FIXME: these user tests should probably be in a set of cardtype specific tests somewhere..
describe User, "with revisions" do
  before do Account.as_bot { @c = Card["Wagn Bot"] } end
  it "should not be removable" do
    @c.destroy.should_not be_true
  end
end

describe User, "without revisions" do
  before do
    Account.as_bot do
      @c = Card.create! :name=>'User Must Die', :type=>'User'
    end
  end
  it "should be removable" do
    @c.destroy!.should be_true
  end
end




#NOT WORKING, BUT IT SHOULD
#describe Card, "a part of an unremovable card" do
#  before do
#     Account.as(Card::WagnBotID)
#     # this ugly setup makes it so A+Admin is the actual user with edits..
#     Card["Wagn Bot"].update_attributes! :name=>"A+Wagn Bot"
#  end
#  it "should not be removable" do
#    @a = Card['A']
#    @a.destroy.should_not be_true
#  end
#end

describe Card, "dependent removal" do
  before do
    Account.as :joe_user
    @a = Card['A']
    @a.destroy!
    @c = Card.find_by_key "A+B+C".to_name.key
  end

  it "should be trash" do
    @c.trash.should be_true
  end

  it "should not be findable by name" do
    Card["A+B+C"].should == nil
  end
end

describe Card, "rename to trashed name" do
  before do
    Account.as_bot do
      @a = Card["A"]
      @b = Card["B"]
      @a.destroy!  #trash
      @b.update_attributes! :name=>"A", :update_referencers=>true
    end
  end

  it "should rename b to a" do
    @b.name.should == 'A'
  end

  it "should rename a to a*trash" do
    (c = Card.find(@a.id)).cardname.to_s.should == 'A*trash'
    c.name.should == 'A*trash'
    c.key.should == 'a*trash'
  end
end


describe Card, "sent to trash" do
  before do
    Account.as_bot do
      @c = Card["basicname"]
      @c.destroy!
    end
  end

  it "should be trash" do
    @c.trash.should == true
  end

  it "should not be findable by name" do
    Card["basicname"].should == nil
  end

  it "should still have revision" do
    @c.revisions.length.should == 1
    @c.current_revision.content.should == 'basiccontent'
  end
end

describe Card, "revived from trash" do
  before do
    Account.as_bot do
      Card["basicname"].destroy!
      @c = Card.create! :name=>'basicname', :content=>'revived content'
    end
  end

  it "should not be trash" do
    @c.trash.should == false
  end

  it "should have 2 revisions" do
    @c.revisions.length.should == 2
  end

  it "should still have old revisions" do
    @c.revisions[0].content.should == 'basiccontent'
  end

  it "should have a new revision" do
    @c.content.should == 'revived content'
#    Card.fetch(@c.name).content.should == 'revived content'
  end
end

describe Card, "recreate trashed card via new" do
#  before do
#    Account.as(Card::WagnBotID)
#    @c = Card.create! :type=>'Basic', :name=>"BasicMe"
#  end

#  this test is known to be broken; we've worked around it for now
#  it "should delete and recreate with a different cardtype" do
#    @c.destroy!
#    @re_c = Card.new :type=>"Phrase", :name=>"BasicMe", :content=>"Banana"
#    @re_c.save!
#  end

end

describe Card, "junction revival" do
  before do
    Account.as_bot do
      @c = Card.create! :name=>"basicname+woot", :content=>"basiccontent"
      @c.destroy!
      @c = Card.create! :name=>"basicname+woot", :content=>"revived content"
    end
  end

  it "should not be trash" do
    @c.trash.should == false
  end

  it "should have 2 revisions" do
    @c.revisions.length.should == 2
  end

  it "should still have old revisions" do
    @c.revisions[0].content.should == 'basiccontent'
  end

  it "should have a new revision" do
    @c.content.should == 'revived content'
  end
end

describe "remove tests" do

  before do
    Account.user = 'joe_user'
    @a = Card["A"]
  end


  # I believe this is here to test a bug where cards with certain kinds of references
  # would fail to delete.  probably less of an issue now that delete is done through
  # trash.
  it "test_remove" do
    assert @a.destroy!, "card should be destroyable"
    assert_nil Card["A"]
  end

  it "test_recreate_plus_card_name_variant" do
    Card.create( :name => "rta+rtb" ).destroy
    Card["rta"].update_attributes :name=> "rta!"
    c = Card.create! :name=>"rta!+rtb"
    assert Card["rta!+rtb"]
    assert !Card["rta!+rtb"].trash
    assert Card.find_by_key('rtb*trash').nil?
  end

  it "test_multiple_trash_collision" do
    Card.create( :name => "alpha" ).destroy
    3.times do
      b = Card.create( :name => "beta" )
      b.name = "alpha"
      assert b.save!
      b.destroy
    end
  end
end

