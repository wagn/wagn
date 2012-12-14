require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Card do
  context "new" do
    it "gracefully handles explicit nil as parameters" do
      Card.new( nil ).should be_instance_of(Card)
    end

    it "gracefully handles explicit nil name" do
      Card.new( :name => nil ).should be_instance_of(Card)
    end
  end

  describe "module inclusion" do
    before do
      Account.as :joe_user
      @c = Card.new :type=>'Search', :name=>'Module Inclusion Test Card'
    end

    it "gets needed methods after new" do
      @c.respond_to?( :get_spec ).should be_true
    end

    it "gets needed methods after save" do
      @c.save!
      @c.respond_to?( :get_spec ).should be_true
    end

#    it "gets needed methods after find" do
#      @c.save!
#      c = Card[@c.name]
#      c.respond_to?( :get_spec ).should be_true
#    end

    it "gets needed methods after fetch" do
      @c.save!
      c = Card.fetch(@c.name)
      c.respond_to?( :get_spec ).should be_true
    end
  end

  describe "pointer module inclusion" do
    before do
      @c_args = { :name=>'Home+*watchers' }
    end

    it "gets needed methods with explicit pointer setting" do
      Rails.logger.info "testing point"
      Card.new(@c_args.merge(:type=>'Pointer')).
               respond_to?(:add_item).should be_true
    end

    it "gets needed methods with implicit pointer setting (from template)" do
      c=Card.new(@c_args)
      Rails.logger.info "testing point #{c.inspect} N:#{c.name}"
      c.respond_to?(:add_item).should be_true
    end
  end


  describe "#create" do
    it "calls :after_create hooks" do
      # We disabled these for the most part, what replaces them?
      #[:before_save, :before_create, :after_save, :after_create].each do |hookname|
      pending "mock rr seems to be broken, maybe 'call' collides with internal methode"
      mock(Wagn::Hook).call(:after_create, instance_of(Card))
      Account.as_bot do
        Card.create :name => "testit"
      end
    end
  end

  describe "test data" do
    it "should be findable by name" do
      Card["Wagn Bot"].class.should == Card
    end
  end

  describe  "new" do
    context "with name" do
      before do
        @c = Card.new :name=>"Ceee"
        @d = Card.new :type=>'Date'
      end

      it "c should have cardtype basic" do
        Rails.logger.info "testing point #{@c} #{@c.inspect}"
        @c.typecode.should == :basic
      end

      it "d should have cardtype Date" do
        Rails.logger.info "testing point #{@d} #{@d.inspect}"
        @d.typecode.should == :date
      end
    end

    it "name is not nil" do
      Card.new.name.should == ""
      Card.new( nil ).name.should == ""
    end
  end

  describe "creation" do
    before(:each) do
      Account.as_bot do
        @b = Card.create! :name=>"New Card", :content=>"Great Content"
        @c = Card.find(@b.id)
      end
    end

    it "should not have errors"        do @b.errors.size.should == 0        end
    it "should have the right class"   do @c.class.should    == Card        end
    it "should have the right key"     do @c.key.should      == "new_card"  end
    it "should have the right name"    do @c.name.should     == "New Card"  end
    it "should have the right content" do @c.content.should  == "Great Content" end

    it "should have a revision with the right content" do
      @c.current_revision.content == "Great Content"
    end

    it "should be findable by name" do
      Card["New Card"].class.should == Card
    end
  end


  describe "attribute tracking for new card" do
    before(:each) do
      Account.as_bot do
        @c = Card.new :name=>"New Card", :content=>"Great Content"
      end
    end

    it "should have updates" do
      Cardlib::AttributeTracking::Updates.should === @c.updates
    end

    it "should return original value" do
      @c.name.should == 'New Card'
    end

    it "should track changes" do
      @c.name = 'Old Card'
      @c.name.should == 'Old Card'
    end
  end

  describe "attribute tracking for existing card" do
    before(:each) do
      @c = Card["Joe User"]
    end
  end

  describe "content change should create new revision" do
    before do
      Account.as_bot do
        @c = Card['basicname']
        @c.update_attributes! :content=>'foo'
      end
    end

    it "should have 2 revisions"  do
      @c.revisions.length.should == 2
    end

    it "should have original revision" do
      @c.revisions[0].content.should == 'basiccontent'
    end
  end


  describe "content change should create new revision" do
    before do
      Account.as_bot do
        @c = Card['basicname']
        @c.content = "foo"
        @c.save!
      end
    end

    it "should have 2 revisions"  do
      @c.revisions.length.should == 2
    end

    it "should have original revision" do
      @c.revisions[0].content.should == 'basiccontent'
    end
  end


  describe "created a virtual card when missing and has a template" do
    it "should be flagged as virtual" do
      Card.new(:name=>'A+*last edited').virtual?.should be_true
    end
  end
end

describe "basic card tests" do


  def assert_simple_card card
    card.name.should be, "name not null"
    card.name.empty?.should be_false, "name not empty"
    rev = card.current_revision
    rev.should be_instance_of Card::Revision
    rev.creator.should be_instance_of Card
  end

  def assert_samecard card1, card2
    assert_equal card1.current_revision, card2.current_revision
  end

  def assert_stable card1
    card2 = Card[card1.name]
    assert_simple_card card1
    assert_simple_card card2
    assert_samecard card1, card2
    assert_equal card1.right, card2.right
  end

  it 'should remove cards' do
    forba = Card.create! :name=>"Forba"
    torga = Card.create! :name=>"TorgA"
    torgb = Card.create! :name=>"TorgB"
    torgc = Card.create! :name=>"TorgC"

    forba_torga = Card.create! :name=>"Forba+TorgA";
    torgb_forba = Card.create! :name=>"TorgB+Forba";
    forba_torga_torgc = Card.create! :name=>"Forba+TorgA+TorgC";

    Card['Forba'].destroy!

    Card["Forba"].should be_nil
    Card["Forba+TorgA"].should be_nil
    Card["TorgB+Forba"].should be_nil
    Card["Forba+TorgA+TorgC"].should be_nil

    # FIXME: this is a pretty dumb test and it takes a loooooooong time
    #while card = Card.find(:first,:conditions=>["type not in (?,?,?) and trash=?", 'AccountRequest','User','Cardtype',false] )
    #  card.destroy!
    #end
    #assert_equal 0, Card.find_all_by_trash(false).size
  end

  #test test_attribute_card
  #  alpha, beta = Card.create(:name=>'alpha'), Card.create(:name=>'beta')
  #  assert_nil alpha.attribute_card('beta')
  #  Card.create :name=>'alpha+beta'
  #   alpha.attribute_card('beta').should be_instance_of(Card)
  #end

  it 'should create cards' do
    alpha = Card.new :name=>'alpha', :content=>'alpha'
    alpha.content.should == 'alpha'
    alpha.save
    alpha.name.should == 'alpha'
    assert_stable alpha
  end


  # just a sanity check that we don't have broken data to start with
  it 'should find cards in database' do
    Card.find(:all).each do |p|
       p.should be_instance_of Card
    end
  end

  it 'should find_by_name' do
    card = Card.create( :name=>"ThisMyCard", :content=>"Contentification is cool" )
    Card["ThisMyCard"].should == card
  end


  it 'should not find nonexistent' do
    Card['no such card+no such tag'].should be_nil
    Card['HomeCard+no such tag'].should be_nil
  end


  it 'update_should_create_subcards' do
    Account.user = 'joe_user'
    Account.as 'joe_user' do

      Card.update (Card.create! :name=>'Banana').id, :cards=>{ "+peel" => { :content => "yellow" }}

      peel = Card['Banana+peel']
      peel.content.       should == "yellow"
      Card['joe_user'].id.should == peel.creator_id
    end
  end

  it 'update_should_create_subcards_as_wagn_bot_if_missing_subcard_permissions' do
    Card.create :name=>'peel'
    Account.user = :anonymous

    Card['Banana'].should_not be
    Card['Basic'].ok?(:create).should be_false, "anon can't creat"

    Card.create! :type=>"Fruit", :name=>'Banana', :cards=>{ "+peel" => { :content => "yellow" }}
    Card['Banana'].should be
    peel = Card["Banana+peel"]

    peel.current_revision.content.should == "yellow"
    peel.creator_id.should == Card::AnonID
  end

  it 'update_should_not_create_subcards_if_missing_main_card_permissions' do
    b = nil
    Account.as(:joe_user) do
      b = Card.create!( :name=>'Banana' )
      #warn "created #{b.inspect}"
    end
    Account.as Card::AnonID do
      assert_raises( Card::PermissionDenied ) do
        Card.update(b.id, :cards=>{ "+peel" => { :content => "yellow" }})
      end
    end
  end


  it 'create_without_read_permission' do
    c = Card.create!({:name=>"Banana", :type=>"Fruit", :content=>"mush"})
    Account.as Card::AnonID do
      assert_raises Card::PermissionDenied do
        c.ok! :read
      end
    end
  end

end
