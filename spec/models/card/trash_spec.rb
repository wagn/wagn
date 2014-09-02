# -*- encoding : utf-8 -*-

require 'card/action'

describe Card, "deleting card" do
  it "should require permission" do
    a = Card['a']
    Card::Auth.as :anonymous do
      a.ok?(:delete).should == false
      a.delete.should == false
      a.errors[:permission_denied].should_not be_empty
      Card['a'].trash.should == false
    end
    
  end
end

describe Card, "deleted card" do
  before do
    Card::Auth.as_bot do
      @c = Card['A']
      @c.delete!
    end
  end
  it "should be in the trash" do
    @c.trash.should be_true
  end
  it "should come out of the trash when a plus card is created" do
    Card::Auth.as_bot do
      Card.create(:name=>'A+*acct')
      c = Card[ 'A' ]
      c.trash.should be_false
    end
  end
end

describe Card, "in trash" do
  it "should be retrieved by fetch with new" do
    Card.create(:name=>"Betty").delete
    c=Card.fetch "Betty", :new=>{}
    c.save
    Card["Betty"].should be_instance_of(Card)
  end
end


describe Card, "plus cards" do
  it "should be deleted when root is" do
    Card::Auth.as :joe_admin do
      c = Card.create! :name=>'zz+top'
      root = Card['zz']
      root.delete
#      Rails.logger.info "ERRORS = #{root.errors.full_messages*''}"
      Card.find(c.id).trash.should be_true
      Card['zz'].should be_nil
    end
  end
end

# FIXME: these user tests should probably be in a set of cardtype specific tests somewhere..
describe Card do
  context "with revisions" do
    before do Card::Auth.as_bot { @c = Card["Wagn Bot"] } end
    it "should not be removable" do
      @c.delete.should_not be_true
    end
  end

  context "without revisions" do
    before do
      Card::Auth.as_bot do
        @c = Card.create! :name=>'User Must Die', :type=>'User'
      end
    end
    it "should be removable" do
      @c.delete!.should be_true
    end
  end
end




#NOT WORKING, BUT IT SHOULD
#describe Card, "a part of an unremovable card" do
#  before do
#     Card::Auth.as(Card::WagnBotID)
#     # this ugly setup makes it so A+Admin is the actual user with edits..
#     Card["Wagn Bot"].update_attributes! :name=>"A+Wagn Bot"
#  end
#  it "should not be removable" do
#    @a = Card['A']
#    @a.delete.should_not be_true
#  end
#end

describe Card, "dependent removal" do
  before do
    @a = Card['A']
    @a.delete!
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
    Card::Auth.as_bot do
      @a = Card["A"]
      @b = Card["B"]
      @a.delete!  #trash
      Rails.logger.info "\n\n~~~~~~~deleted~~~~~~~~\n\n\n"
      
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
    Card::Auth.as_bot do
      @c = Card["basicname"]
      @c.delete!
    end
  end

  it "should be trash" do
    @c.trash.should == true
  end

  it "should not be findable by name" do
    Card["basicname"].should == nil
  end

  it "should still have actions" do
    @c.actions.length.should == 2
    @c.last_change_on(:db_content).value.should == 'basiccontent'
  end
end

describe Card, "revived from trash" do
  before do
    Card::Auth.as_bot do
      Card["basicname"].delete!
      
      @c = Card.create! :name=>'basicname', :content=>'revived content'
    end
  end

  it "should not be trash" do
    @c.trash.should == false
  end

  it "should have 3 actions" do
    @c.actions.count.should == 3
  end

  it "should still have old content" do
    @c.nth_revision(1)[:db_content].should == 'basiccontent'
  end

  it "should have the same content" do
    @c.content.should == 'revived content'
#    Card.fetch(@c.name).content.should == 'revived content'
  end
end

describe Card, "recreate trashed card via new" do
#  before do
#    Card::Auth.as(Card::WagnBotID)
#    @c = Card.create! :type=>'Basic', :name=>"BasicMe"
#  end

#  this test is known to be broken; we've worked around it for now
#  it "should delete and recreate with a different cardtype" do
#    @c.delete!
#    @re_c = Card.new :type=>"Phrase", :name=>"BasicMe", :content=>"Banana"
#    @re_c.save!
#  end

end

describe Card, "junction revival" do
  before do
    Card::Auth.as_bot do
      @c = Card.create! :name=>"basicname+woot", :content=>"basiccontent"
      @c.delete!
      @c = Card.create! :name=>"basicname+woot", :content=>"revived content"
    end
  end

  it "should not be trash" do
    @c.trash.should == false
  end

  it "should have 3 actions" do
    @c.actions.count.should == 3
  end

  it "should still have old action" do
    @c.nth_revision(1)[:db_content].should == 'basiccontent'
  end

  it "should have old content" do
    @c.db_content.should == 'revived content'
  end
end

describe "remove tests" do

  before do
    @a = Card["A"]
  end

  # I believe this is here to test a bug where cards with certain kinds of references
  # would fail to delete.  probably less of an issue now that delete is done through
  # trash.
  it "test_remove" do
    assert @a.delete!, "card should be deleteable"
    assert_nil Card["A"]
  end

  it "test_recreate_plus_card_name_variant" do
    Card.create( :name => "rta+rtb" ).delete
    Card["rta"].update_attributes :name=> "rta!"
    c = Card.create! :name=>"rta!+rtb"
    assert Card["rta!+rtb"]
    assert !Card["rta!+rtb"].trash
    assert Card.find_by_key('rtb*trash').nil?
  end

  it "test_multiple_trash_collision" do
    Card.create( :name => "alpha" ).delete
    3.times do
      b = Card.create( :name => "beta" )
      b.name = "alpha"
      assert b.save!
      b.delete
    end
  end
end

