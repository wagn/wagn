# -*- encoding : utf-8 -*-

require "card/action"

describe Card, "deleting card" do
  it "should require permission" do
    a = Card["a"]
    Card::Auth.as :anonymous do
      expect(a.ok?(:delete)).to eq(false)
      expect(a.delete).to eq(false)
      expect(a.errors[:permission_denied]).not_to be_empty
      expect(Card["a"].trash).to eq(false)
    end
  end
end

describe Card, "deleted card" do
  before do
    Card::Auth.as_bot do
      @c = Card["A"]
      @c.delete!
    end
  end
  it "should be in the trash" do
    expect(@c.trash).to be_truthy
  end
  it "should come out of the trash when a plus card is created" do
    Card::Auth.as_bot do
      Card.create(name: "A+*acct")
      c = Card["A"]
      expect(c.trash).to be_falsey
    end
  end
end

describe Card, "in trash" do
  it "should be retrieved by fetch with new" do
    Card.create(name: "Betty").delete
    c = Card.fetch "Betty", new: {}
    c.save
    expect(Card["Betty"]).to be_instance_of(Card)
  end
end

describe Card, "plus cards" do
  it "should be deleted when root is" do
    Card::Auth.as "joe_admin" do
      c = Card.create! name: "zz+top"
      root = Card["zz"]
      root.delete
      #      Rails.logger.info "ERRORS = #{root.errors.full_messages*''}"
      expect(Card.find(c.id).trash).to be_truthy
      expect(Card["zz"]).to be_nil
    end
  end
end

# FIXME: these user tests should probably be in a set of cardtype specific tests somewhere..
describe Card do
  context "with revisions" do
    before { Card::Auth.as_bot { @c = Card["Wagn Bot"] } }
    it "should not be removable" do
      expect(@c.delete).not_to be_truthy
    end
  end

  context "without revisions" do
    before do
      Card::Auth.as_bot do
        @c = Card.create! name: "User Must Die", type: "User"
      end
    end
    it "should be removable" do
      expect(@c.delete!).to be_truthy
    end
  end
end

# NOT WORKING, BUT IT SHOULD
# describe Card, "a part of an unremovable card" do
#  before do
#     Card::Auth.as(Card::WagnBotID)
#     # this ugly setup makes it so A+Admin is the actual user with edits..
#     Card["Wagn Bot"].update_attributes! name: "A+Wagn Bot"
#  end
#  it "should not be removable" do
#    @a = Card['A']
#    @a.delete.should_not be_true
#  end
# end

describe Card, "dependent removal" do
  before do
    @a = Card["A"]
    @a.delete!
    @c = Card.find_by_key "A+B+C".to_name.key
  end

  it "should be trash" do
    expect(@c.trash).to be_truthy
  end

  it "should not be findable by name" do
    expect(Card["A+B+C"]).to eq(nil)
  end
end

describe Card, "rename to trashed name" do
  before do
    Card::Auth.as_bot do
      @a = Card["A"]
      @b = Card["B"]
      @a.delete!  # trash
      Rails.logger.info "\n\n~~~~~~~deleted~~~~~~~~\n\n\n"

      @b.update_attributes! name: "A", update_referers: true
    end
  end

  it "should rename b to a" do
    expect(@b.name).to eq("A")
  end

  it "should rename a to a*trash" do
    expect((c = Card.find(@a.id)).cardname.to_s).to eq("A*trash")
    expect(c.name).to eq("A*trash")
    expect(c.key).to eq("a*trash")
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
    expect(@c.trash).to eq(true)
  end

  it "should not be findable by name" do
    expect(Card["basicname"]).to eq(nil)
  end

  it "should still have actions" do
    expect(@c.actions.count).to eq(2)
    expect(@c.last_change_on(:db_content).value).to eq("basiccontent")
  end
end

describe Card, "revived from trash" do
  before do
    Card::Auth.as_bot do
      Card["basicname"].delete!

      @c = Card.create! name: "basicname", content: "revived content"
    end
  end

  it "should not be trash" do
    expect(@c.trash).to eq(false)
  end

  it "should have 3 actions" do
    expect(@c.actions.count).to eq(3)
  end

  it "should still have old content" do
    expect(@c.nth_action(1).value :db_content).to eq("basiccontent")
  end

  it "should have the same content" do
    expect(@c.content).to eq("revived content")
    #    Card.fetch(@c.name).content.should == 'revived content'
  end
end

describe Card, "recreate trashed card via new" do
  #  before do
  #    Card::Auth.as(Card::WagnBotID)
  #    @c = Card.create! type: 'Basic', name: "BasicMe"
  #  end

  #  this test is known to be broken; we've worked around it for now
  #  it "should delete and recreate with a different cardtype" do
  #    @c.delete!
  #    @re_c = Card.new type: "Phrase", name: "BasicMe", content: "Banana"
  #    @re_c.save!
  #  end
end

describe Card, "junction revival" do
  before do
    Card::Auth.as_bot do
      @c = Card.create! name: "basicname+woot", content: "basiccontent"
      @c.delete!
      @c = Card.create! name: "basicname+woot", content: "revived content"
    end
  end

  it "should not be trash" do
    expect(@c.trash).to eq(false)
  end

  it "should have 3 actions" do
    expect(@c.actions.count).to eq(3)
  end

  it "should still have old action" do
    expect(@c.nth_action(1).value :db_content).to eq("basiccontent")
  end

  it "should have old content" do
    expect(@c.db_content).to eq("revived content")
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
    Card.create(name: "rta+rtb").delete
    Card["rta"].update_attributes name: "rta!"
    c = Card.create! name: "rta!+rtb"
    assert Card["rta!+rtb"]
    assert !Card["rta!+rtb"].trash
    assert Card.find_by_key("rtb*trash").nil?
  end

  it "test_multiple_trash_collision" do
    Card.create(name: "alpha").delete
    3.times do
      b = Card.create(name: "beta")
      b.name = "alpha"
      assert b.save!
      b.delete
    end
  end
end
