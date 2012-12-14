require File.expand_path('../../spec_helper', File.dirname(__FILE__))

module RenameMethods
  def name_invariant_attributes card
    {
      :content => card.content,
#      :writer => card.writer,
      :revisions => card.revisions.length,
      :referencers => card.referencers.map(&:name).sort,
      :referencees => card.referencees.map(&:name).sort,
      :dependents => card.dependents.map(&:id)
    }
  end

  def assert_rename card, new_name
    attrs_before = name_invariant_attributes( card )
    card.name=new_name
    card.update_referencers = true
    card.save!
    assert_equal attrs_before, name_invariant_attributes(card)
    assert_equal new_name, card.name
    assert Card[new_name]
  end

  def card name
    Card[name].refresh or raise "Couldn't find card named #{name}"
  end
end

describe Card, "Case Variant" do
  before do
    Account.as :joe_user
    @c = Card.create! :name=>'chump'
  end

  it "should be able to change to a capitalization" do
    @c.name.should == 'chump'
    @c.name = 'Chump'
    @c.save!
    @c.name.should == 'Chump'
  end
end


describe SmartName, "Underscores" do
  it "should be treated like spaces when making keys" do
    'weird_ combo'.to_name.key.should == 'weird  combo'.to_name.key
  end
  it "should not impede pluralization checks" do
    'Mamas_and_Papas'.to_name.key.should == "Mamas and Papas".to_name.key
  end
end

describe SmartName, "changing from plus card to simple" do
  before do
    Account.as :joe_user
    @c = Card.create! :name=>'four+five'
    @c.name = 'nine'
    @c.save
  end

  it "should erase trunk and tag ids" do
    @c.trunk_id.should== nil
    @c.tag_id.should== nil
  end

  it "test_fetch_or_create_when_present" do
    Card.create!(:name=>"Carrots")
    cards_should_be_added 0 do
      Card.fetch_or_create("Carrots").should be_instance_of(Card)
    end
  end

  it "test_simple" do
    cards_should_be_added 1 do
      Card['Boo!'].should be_nil
      Card.create(:name=>"Boo!").should be_instance_of(Card)
      Card['Boo!'].should be_instance_of(Card)
    end
  end


  it "test_fetch_or_create_when_not_present" do
    cards_should_be_added 1 do
      Card.fetch_or_create("Tomatoes").should be_instance_of(Card)
    end
  end

  it "test_create_junction" do
    cards_should_be_added 3 do
      Card.create(:name=>"Peach+Pear", :content=>"juicy").should be_instance_of(Card)
    end
    Card["Peach"].should be_instance_of(Card)
    Card["Pear"].should be_instance_of(Card)
    assert_equal "juicy", Card["Peach+Pear"].content
  end

  def cards_should_be_added number
    number += Card.all.count
    yield
    Card.all.count.should == number
  end


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

describe "rename tests" do
  include RenameMethods


  # FIXME: these tests are TOO SLOW!  8s against server, 12s from command line.
  # not sure if it's the card creation or the actual renaming process.
  # Card#save needs optimized in general.
  # Can't we just move this data to fixtures?
  before do
    Account.as_bot do
     Card.create! :name => "chuck_wagn+chuck"
     Card.create! :name => "Blue"
     
     Card.create! :name => "blue includer 1", :content => "{{Blue}}"
     Card.create! :name => "blue includer 2", :content => "{{blue|closed;other:stuff}}"
     
     Card.create! :name => "blue linker 1", :content => "[[Blue]]"
     Card.create! :name => "blue linker 2", :content => "[[blue]]"
     
     Card.create! :type=>"Cardtype", :name=>"Dairy", :content => "[[/new/{{_self|name}}|new]]"
     
     c3, c4 = Card["chuck_wagn+chuck"], Card["chuck"]
    end
    Account.user = 'joe_user'
  end

  it "test_subdivision" do
    assert_rename card("A+B"), "A+B+T"  # re-uses the parent card: A+B
  end

  it "test_rename_name_substitution" do
    c1, c2 = Card["chuck_wagn+chuck"], Card["chuck"]
    assert_rename c2, "buck"
    assert_equal "chuck_wagn+buck", Card.find(c1.id).name
  end

  it "test_rename_same_key_with_dependents" do
    assert_rename card("B"), "b"
  end

  it "test_junction_to_simple" do
    assert_rename card("A+B"), "K"
  end

  it "test_reference_updates_plus_to_simple" do
     c1, c2 = Card['Blue'], Card["chuck_wagn+chuck"]
     c1.content = "[[chuck wagn+chuck]]"
     c1.save!
     assert_rename c2, 'schmuck'
     assert_equal '[[schmuck]]', Card.find(c1.id).content
  end

  it "test_updates_inclusions_when_renaming" do
    c1,c2,c3 = Card["Blue"], Card["blue includer 1"], Card["blue includer 2"]
    c1.update_attributes :name => "Red", :update_referencers => true
    assert_equal "{{Red}}", Card.find(c2.id).content                     
    # NOTE these attrs pass through a hash stage that may not preserve order
    assert_equal "{{Red|closed;other:stuff}}", Card.find(c3.id).content
  end

  it "test_updates_inclusions_when_renaming_to_plus" do
    c1,c2 = Card["Blue"], Card["blue includer 1"]
    c1.update_attributes :name => "blue includer 1+color", :update_referencers => true
    assert_equal "{{blue includer 1+color}}", Card.find(c2.id).content                     
  end

  it "test_reference_updates_on_case_variants" do
    c1,c2,c3 = Card["Blue"], Card["blue linker 1"], Card["blue linker 2"]
    c1.reload.name = "Red"
    c1.update_referencers = true
    c1.save!
    assert_equal "[[Red]]", Card.find(c2.id).content
    assert_equal "[[Red]]", Card.find(c3.id).content
  end

  it "test_flip" do
    assert_rename card("A+B"), "B+A"
  end

  it "test_should_error_card_exists" do
    @t=card("T"); @t.name="A+B";
    assert !@t.save, "save should fail"
    assert @t.errors[:name], "should have errors on key"
  end

  it "test_used_as_tag" do
    @b=card("B"); @b.name='A+D'; @b.save
    assert @b.errors[:name]
  end

  it "test_update_dependents" do
    c1 =   Card["One"]
    c12 =  Card["One+Two"]
    c123 = Card["One+Two+Three"]
    c41 =  Card["Four+One"]
    c415 = Card["Four+One+Five"]

    assert_equal ["One+Two","One+Two+Three","Four+One","Four+One+Five"], [c12,c123,c41,c415].map(&:name)
    c1.name="Uno"
    c1.save!
    assert_equal ["Uno+Two","Uno+Two+Three","Four+Uno","Four+Uno+Five"], [c12,c123,c41,c415].map(&:reload).map(&:name)
  end

  it "test_should_error_invalid_name" do
    @t=card("T"); @t.name="YT_o~Yo"; @t.save
    assert @t.errors[:name]
  end

  it "test_simple_to_simple" do
    assert_rename card("A"), "Alephant"
  end

  it "test_simple_to_junction_with_create" do
    assert_rename card("T"), "C+J"
  end

  it "test_reset_key" do
    c = Card["Basic Card"]
    c.name="banana card"
    c.save!
    assert_equal 'banana_card', c.key
    assert Card["Banana Card"] != nil
  end

  it "test_renaming_card_with_self_link_should_not_hang" do
    c = Card["Dairy"]
    c.name = "Buttah"
    c.update_referencers = true
    c.save!
    assert_equal "[[/new/{{_self|name}}|new]]", Card["Buttah"].content
  end

  it "test_renaming_card_without_updating_references_should_not_have_errors" do
    c = Card["Dairy"]
    c.update_attributes "name"=>"Newt", "update_referencers"=>'false'
    assert_equal "[[/new/{{_self|name}}|new]]", Card["Newt"].content
  end

  it "test_rename_should_not_fail_when_updating_inaccessible_referencer" do
    Card.create! :name => "Joe Card", :content => "Whattup"
    Account.as :joe_admin do
      Card.create! :name => "Admin Card", :content => "[[Joe Card]]"
    end
    c = Card["Joe Card"]
    c.update_attributes! :name => "Card of Joe", :update_referencers => true
    assert_equal "[[Card of Joe]]", Card["Admin Card"].content
  end

  it "test_rename_should_not_fail_when_updating_hard_templated_referencer" do
    c=Card.create! :name => "Pit"
    Card.create! :name => "Orange", :type=>"Fruit", :content => "[[Pit]]"
    Card["Fruit+*type+*default"].update_attributes(:content=>"this [[Pit]]")

    assert_equal "this [[Pit]]", Card["Orange"].content
    c.update_attributes! :name => "Seed", :update_referencers => true
    assert true  # just make sure nothing exploded
  end
end

=begin
test/unit/card/search_test.rb:require File.expand_path('../../test_helper', File.dirname(__FILE__))
test/unit/card/search_test.rb:class Card::BaseTest < ActiveSupport::TestCase
test/unit/card/search_test.rb:
test/unit/card/search_test.rb:  def setup
test/unit/card/search_test.rb:    super
test/unit/card/search_test.rb:    Account.as(cid=Card['u3'].id)  # FIXME!!! wtf?  this works and :admin doesn't
test/unit/card/search_test.rb:  end
test/unit/card/search_test.rb:
test/unit/card/search_test.rb:  def test_autocard_should_not_respond_to_tform
test/unit/card/search_test.rb:    assert_nil Card.fetch("u1+*type+*content")
test/unit/card/search_test.rb:  end
test/unit/card/search_test.rb:
test/unit/card/search_test.rb:  def test_autocard_should_respond_to_ampersand_email_attribute
test/unit/card/search_test.rb:    assert c = Card.fetch_or_new("u1+*email")
test/unit/card/search_test.rb:
test/unit/card/search_test.rb:    assert_equal 'u1@user.com', Wagn::Renderer.new(c).render_raw
test/unit/card/search_test.rb:  end
test/unit/card/search_test.rb:
test/unit/card/search_test.rb:  def test_autocard_should_not_respond_to_not_templated_or_ampersanded_card
test/unit/card/search_test.rb:    assert_nil Card.fetch("u1+email")
test/unit/card/search_test.rb:  end
test/unit/card/search_test.rb:
test/unit/card/search_test.rb:  def test_should_not_show_card_to_joe_user
test/unit/card/search_test.rb:    # FIXME: this needs some permission rules
test/unit/card/search_test.rb:    Account.as(:joe_user)
test/unit/card/search_test.rb:    assert c=Card.fetch("u1+*email")
test/unit/card/search_test.rb:    assert_equal false, c.ok?(:read)
test/unit/card/search_test.rb:  end
test/unit/card/search_test.rb:
test/unit/card/search_test.rb:  def test_autocard_should_not_break_if_extension_missing
test/unit/card/search_test.rb:    assert_equal '', Wagn::Renderer.new(Card.fetch("A+*email")).render_raw
test/unit/card/search_test.rb:  end
test/unit/card/search_test.rb:end
=end
