require File.expand_path('../../spec_helper', File.dirname(__FILE__))
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
    assert_difference Card, :count, 0 do
      Card.fetch_or_create("Carrots").should be_instance_of(Card)
    end
  end

  it "test_simple" do
    assert_difference Card, :count do
      Card.create(:name=>"Boo!").should be_instance_of(Card).should be_instance_of(Card)
      Card["Boo!"].should be
    end
  end


  it "test_fetch_or_create_when_not_present" do
    assert_difference Card, :count do
      Card.fetch_or_create("Tomatoes").should be_instance_of(Card)
    end
  end

  it "test_create_junction" do
    assert_difference(Card, :count, 3) do
      Card.create(:name=>"Peach+Pear", :content=>"juicy").should be_instance_of(Card)
    end
    Card["Peach"].should be_instance_of(Card)
    Card["Pear"].should be_instance_of(Card)
    assert_equal "juicy", Card["Peach+Pear"].content
  end

  def assert_difference object, method, number=1
    number += object.send(method)
    yield
    object.send(method).should == number
  end

end

=begin
test/unit/card/base_test.rb:require File.expand_path('../../test_helper', File.dirname(__FILE__))
test/unit/card/base_test.rb:class Card::BaseTest < ActiveSupport::TestCase
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  def setup
test/unit/card/base_test.rb:    super
test/unit/card/base_test.rb:    setup_default_user
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'remove' do
test/unit/card/base_test.rb:    forba = Card.create! :name=>"Forba"
test/unit/card/base_test.rb:    torga = Card.create! :name=>"TorgA"
test/unit/card/base_test.rb:    torgb = Card.create! :name=>"TorgB"
test/unit/card/base_test.rb:    torgc = Card.create! :name=>"TorgC"
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:    forba_torga = Card.create! :name=>"Forba+TorgA";
test/unit/card/base_test.rb:    torgb_forba = Card.create! :name=>"TorgB+Forba";
test/unit/card/base_test.rb:    forba_torga_torgc = Card.create! :name=>"Forba+TorgA+TorgC";
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:    forba.reload #hmmm
test/unit/card/base_test.rb:    Card['Forba'].destroy!
test/unit/card/base_test.rb:    assert_nil Card["Forba"]
test/unit/card/base_test.rb:    assert_nil Card["Forba+TorgA"]
test/unit/card/base_test.rb:    assert_nil Card["TorgB+Forba"]
test/unit/card/base_test.rb:    assert_nil Card["Forba+TorgA+TorgC"]
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:    # FIXME: this is a pretty dumb test and it takes a loooooooong time
test/unit/card/base_test.rb:    #while card = Card.find(:first,:conditions=>["type not in (?,?,?) and trash=?", 'AccountRequest','User','Cardtype',false] )
test/unit/card/base_test.rb:    #  card.destroy!
test/unit/card/base_test.rb:    #end
test/unit/card/base_test.rb:    #assert_equal 0, Card.find_all_by_trash(false).size
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  #test test_attribute_card
test/unit/card/base_test.rb:  #  alpha, beta = Card.create(:name=>'alpha'), Card.create(:name=>'beta')
test/unit/card/base_test.rb:  #  assert_nil alpha.attribute_card('beta')
test/unit/card/base_test.rb:  #  Card.create :name=>'alpha+beta'
test/unit/card/base_test.rb:  #   alpha.attribute_card('beta').should be_instance_of(Card)
test/unit/card/base_test.rb:  #end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'create' do
test/unit/card/base_test.rb:    alpha = Card.new :name=>'alpha', :content=>'alpha'
test/unit/card/base_test.rb:    assert_equal 'alpha', alpha.content
test/unit/card/base_test.rb:    #warn "About to save #{alpha.inspect}"
test/unit/card/base_test.rb:    alpha.save
test/unit/card/base_test.rb:    assert alpha.name
test/unit/card/base_test.rb:    assert_stable(alpha)
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  # just a sanity check that we don't have broken data to start with
test/unit/card/base_test.rb:  test 'fixtures' do
test/unit/card/base_test.rb:    Card.find(:all).each do |p|
test/unit/card/base_test.rb:       p.name.should be_instance_of(Card)
test/unit/card/base_test.rb:    end
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'find_by_name' do
test/unit/card/base_test.rb:    card = Card.create( :name=>"ThisMyCard", :content=>"Contentification is cool" )
test/unit/card/base_test.rb:    assert_equal card, Card["ThisMyCard"]
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'find_nonexistent' do
test/unit/card/base_test.rb:    assert !Card['no such card+no such tag']
test/unit/card/base_test.rb:    assert !Card['HomeCard+no such tag']
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'update_should_create_subcards' do
test/unit/card/base_test.rb:    Account.user = 'joe_user'
test/unit/card/base_test.rb:    Account.as(:joe_user) do
test/unit/card/base_test.rb:      c=Card.create!( :name=>'Banana' )
test/unit/card/base_test.rb:      #warn "created #{c.inspect}"
test/unit/card/base_test.rb:      Card.update(c.id, :cards=>{ "+peel" => { :content => "yellow" }})
test/unit/card/base_test.rb:      p = Card['Banana+peel']
test/unit/card/base_test.rb:      assert_equal "yellow", p.content
test/unit/card/base_test.rb:      #warn "creator_id #{p.creator_id}, #{p.updater_id}, #{p.created_at}"
test/unit/card/base_test.rb:      assert_equal Card['joe_user'].id, p.creator_id
test/unit/card/base_test.rb:    end
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'update_should_create_subcards_as_wagn_bot_if_missing_subcard_permissions' do
test/unit/card/base_test.rb:    Card.create(:name=>'peel')
test/unit/card/base_test.rb:    Account.user = :anonymous
test/unit/card/base_test.rb:    #warn Rails.logger.info("check #{Account.user_id}")
test/unit/card/base_test.rb:    assert_equal false, Card['Basic'].ok?(:create), "anon can't creat"
test/unit/card/base_test.rb:    Card.create!( :type=>"Fruit", :name=>'Banana', :cards=>{ "+peel" => { :content => "yellow" }})
test/unit/card/base_test.rb:    peel= Card["Banana+peel"]
test/unit/card/base_test.rb:    #warn "peel #{peel.creator_id}, #{peel.updater_id}, #{peel.created_at}"
test/unit/card/base_test.rb:    assert_equal "yellow", peel.current_revision.content
test/unit/card/base_test.rb:    assert_equal Card::AnonID, peel.creator_id
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'update_should_not_create_subcards_if_missing_main_card_permissions' do
test/unit/card/base_test.rb:    b = nil
test/unit/card/base_test.rb:    Account.as(:joe_user) do
test/unit/card/base_test.rb:      b = Card.create!( :name=>'Banana' )
test/unit/card/base_test.rb:      #warn "created #{b.inspect}"
test/unit/card/base_test.rb:    end
test/unit/card/base_test.rb:    Account.as Card::AnonID do
test/unit/card/base_test.rb:      assert_raises( Card::PermissionDenied ) do
test/unit/card/base_test.rb:        Card.update(b.id, :cards=>{ "+peel" => { :content => "yellow" }})
test/unit/card/base_test.rb:      end
test/unit/card/base_test.rb:    end
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  test 'create_without_read_permission' do
test/unit/card/base_test.rb:    c = Card.create!({:name=>"Banana", :type=>"Fruit", :content=>"mush"})
test/unit/card/base_test.rb:    Account.as Card::AnonID do
test/unit/card/base_test.rb:      assert_raises Card::PermissionDenied do
test/unit/card/base_test.rb:        c.ok! :read
test/unit/card/base_test.rb:      end
test/unit/card/base_test.rb:    end
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  private
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  def assert_simple_card( card )
test/unit/card/base_test.rb:    assert !card.name.nil?, "name not null"
test/unit/card/base_test.rb:    assert !card.name.empty?, "name not empty"
test/unit/card/base_test.rb:    rev = card.current_revision
test/unit/card/base_test.rb:     rev.should be_instance_of(Card)
test/unit/card/base_test.rb:     rev.creator.should be_instance_of(Card)
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  def assert_samecard( card1, card2 )
test/unit/card/base_test.rb:    assert_equal card1.current_revision, card2.current_revision
test/unit/card/base_test.rb:    assert_equal card1.right, card2.right
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:
test/unit/card/base_test.rb:  def assert_stable( card1 )
test/unit/card/base_test.rb:    card2 = Card[card1.name]
test/unit/card/base_test.rb:    assert_simple_card( card1 )
test/unit/card/base_test.rb:    assert_simple_card( card2 )
test/unit/card/base_test.rb:    assert_samecard( card1, card2 )
test/unit/card/base_test.rb:  end
test/unit/card/base_test.rb:end
test/unit/card/base_test.rb:
test/unit/card/create_test.rb:
test/unit/card/remove_test.rb:require File.expand_path('../../test_helper', File.dirname(__FILE__))
test/unit/card/remove_test.rb:class Card::RemoveTest < ActiveSupport::TestCase
test/unit/card/remove_test.rb:
test/unit/card/remove_test.rb:
test/unit/card/remove_test.rb:  def setup
test/unit/card/remove_test.rb:    super
test/unit/card/remove_test.rb:    setup_default_user
test/unit/card/remove_test.rb:    @a = Card["A"]
test/unit/card/remove_test.rb:  end
test/unit/card/remove_test.rb:
test/unit/card/remove_test.rb:
test/unit/card/remove_test.rb:  # I believe this is here to test a bug where cards with certain kinds of references
test/unit/card/remove_test.rb:  # would fail to delete.  probably less of an issue now that delete is done through
test/unit/card/remove_test.rb:  # trash.
test/unit/card/remove_test.rb:  def test_remove
test/unit/card/remove_test.rb:    assert @a.destroy!, "card should be destroyable"
test/unit/card/remove_test.rb:    assert_nil Card["A"]
test/unit/card/remove_test.rb:  end
test/unit/card/remove_test.rb:
test/unit/card/remove_test.rb:  def test_recreate_plus_card_name_variant
test/unit/card/remove_test.rb:    Card.create( :name => "rta+rtb" ).destroy
test/unit/card/remove_test.rb:    Card["rta"].update_attributes :name=> "rta!"
test/unit/card/remove_test.rb:    c = Card.create! :name=>"rta!+rtb"
test/unit/card/remove_test.rb:    assert Card["rta!+rtb"]
test/unit/card/remove_test.rb:    assert !Card["rta!+rtb"].trash
test/unit/card/remove_test.rb:    assert Card.find_by_key('rtb*trash').nil?
test/unit/card/remove_test.rb:end
test/unit/card/remove_test.rb:
test/unit/card/remove_test.rb:  def test_multiple_trash_collision
test/unit/card/remove_test.rb:    Card.create( :name => "alpha" ).destroy
test/unit/card/remove_test.rb:    3.times do
test/unit/card/remove_test.rb:      b = Card.create( :name => "beta" )
test/unit/card/remove_test.rb:      b.name = "alpha"
test/unit/card/remove_test.rb:      assert b.save!
test/unit/card/remove_test.rb:      b.destroy
test/unit/card/remove_test.rb:    end
test/unit/card/remove_test.rb:  end
test/unit/card/remove_test.rb:
test/unit/card/remove_test.rb:end
test/unit/card/remove_test.rb:
test/unit/card/rename_test.rb:require File.expand_path('../../test_helper', File.dirname(__FILE__))
test/unit/card/rename_test.rb:class Card::RenameTest < ActiveSupport::TestCase
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  # FIXME: these tests are TOO SLOW!  8s against server, 12s from command line.
test/unit/card/rename_test.rb:  # not sure if it's the card creation or the actual renaming process.
test/unit/card/rename_test.rb:  # Card#save needs optimized in general.
test/unit/card/rename_test.rb:  def self.add_test_data
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def setup
test/unit/card/rename_test.rb:    super
test/unit/card/rename_test.rb:    Account.as_bot do
test/unit/card/rename_test.rb:     Card.create! :name => "chuck_wagn+chuck"
test/unit/card/rename_test.rb:     Card.create! :name => "Blue"
test/unit/card/rename_test.rb:     
test/unit/card/rename_test.rb:     Card.create! :name => "blue includer 1", :content => "{{Blue}}"
test/unit/card/rename_test.rb:     Card.create! :name => "blue includer 2", :content => "{{blue|closed;other:stuff}}"
test/unit/card/rename_test.rb:     
test/unit/card/rename_test.rb:     Card.create! :name => "blue linker 1", :content => "[[Blue]]"
test/unit/card/rename_test.rb:     Card.create! :name => "blue linker 2", :content => "[[blue]]"
test/unit/card/rename_test.rb:     
test/unit/card/rename_test.rb:     Card.create! :type=>"Cardtype", :name=>"Dairy", :content => "[[/new/{{_self|name}}|new]]"
test/unit/card/rename_test.rb:     
test/unit/card/rename_test.rb:     c3, c4 = Card["chuck_wagn+chuck"], Card["chuck"]
test/unit/card/rename_test.rb:    end
test/unit/card/rename_test.rb:    setup_default_user
test/unit/card/rename_test.rb:    super
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_subdivision
test/unit/card/rename_test.rb:    assert_rename card("A+B"), "A+B+T"  # re-uses the parent card: A+B
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_rename_name_substitution
test/unit/card/rename_test.rb:    c1, c2 = Card["chuck_wagn+chuck"], Card["chuck"]
test/unit/card/rename_test.rb:    assert_rename c2, "buck"
test/unit/card/rename_test.rb:    assert_equal "chuck_wagn+buck", Card.find(c1.id).name
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_rename_same_key_with_dependents
test/unit/card/rename_test.rb:    assert_rename card("B"), "b"
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_junction_to_simple
test/unit/card/rename_test.rb:    assert_rename card("A+B"), "K"
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_reference_updates_plus_to_simple
test/unit/card/rename_test.rb:     c1, c2 = Card['Blue'], Card["chuck_wagn+chuck"]
test/unit/card/rename_test.rb:     c1.content = "[[chuck wagn+chuck]]"
test/unit/card/rename_test.rb:     c1.save!
test/unit/card/rename_test.rb:     assert_rename c2, 'schmuck'
test/unit/card/rename_test.rb:     assert_equal '[[schmuck]]', Card.find(c1.id).content
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_updates_inclusions_when_renaming
test/unit/card/rename_test.rb:    c1,c2,c3 = Card["Blue"], Card["blue includer 1"], Card["blue includer 2"]
test/unit/card/rename_test.rb:    c1.update_attributes :name => "Red", :update_referencers => true
test/unit/card/rename_test.rb:    assert_equal "{{Red}}", Card.find(c2.id).content                     
test/unit/card/rename_test.rb:    # NOTE these attrs pass through a hash stage that may not preserve order
test/unit/card/rename_test.rb:    assert_equal "{{Red|closed;other:stuff}}", Card.find(c3.id).content
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_updates_inclusions_when_renaming_to_plus
test/unit/card/rename_test.rb:    c1,c2 = Card["Blue"], Card["blue includer 1"]
test/unit/card/rename_test.rb:    c1.update_attributes :name => "blue includer 1+color", :update_referencers => true
test/unit/card/rename_test.rb:    assert_equal "{{blue includer 1+color}}", Card.find(c2.id).content                     
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_reference_updates_on_case_variants
test/unit/card/rename_test.rb:    c1,c2,c3 = Card["Blue"], Card["blue linker 1"], Card["blue linker 2"]
test/unit/card/rename_test.rb:    c1.reload.name = "Red"
test/unit/card/rename_test.rb:    c1.update_referencers = true
test/unit/card/rename_test.rb:    c1.save!
test/unit/card/rename_test.rb:    assert_equal "[[Red]]", Card.find(c2.id).content
test/unit/card/rename_test.rb:    assert_equal "[[Red]]", Card.find(c3.id).content
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_flip
test/unit/card/rename_test.rb:    assert_rename card("A+B"), "B+A"
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_should_error_card_exists
test/unit/card/rename_test.rb:    @t=card("T"); @t.name="A+B";
test/unit/card/rename_test.rb:    assert !@t.save, "save should fail"
test/unit/card/rename_test.rb:    assert @t.errors[:name], "should have errors on key"
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_used_as_tag
test/unit/card/rename_test.rb:    @b=card("B"); @b.name='A+D'; @b.save
test/unit/card/rename_test.rb:    assert @b.errors[:name]
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_update_dependents
test/unit/card/rename_test.rb:    c1 =   Card["One"]
test/unit/card/rename_test.rb:    c12 =  Card["One+Two"]
test/unit/card/rename_test.rb:    c123 = Card["One+Two+Three"]
test/unit/card/rename_test.rb:    c41 =  Card["Four+One"]
test/unit/card/rename_test.rb:    c415 = Card["Four+One+Five"]
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:    assert_equal ["One+Two","One+Two+Three","Four+One","Four+One+Five"], [c12,c123,c41,c415].map(&:name)
test/unit/card/rename_test.rb:    c1.name="Uno"
test/unit/card/rename_test.rb:    c1.save!
test/unit/card/rename_test.rb:    assert_equal ["Uno+Two","Uno+Two+Three","Four+Uno","Four+Uno+Five"], [c12,c123,c41,c415].map(&:reload).map(&:name)
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_should_error_invalid_name
test/unit/card/rename_test.rb:    @t=card("T"); @t.name="YT_o~Yo"; @t.save
test/unit/card/rename_test.rb:    assert @t.errors[:name]
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_simple_to_simple
test/unit/card/rename_test.rb:    assert_rename card("A"), "Alephant"
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_simple_to_junction_with_create
test/unit/card/rename_test.rb:    assert_rename card("T"), "C+J"
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_reset_key
test/unit/card/rename_test.rb:    c = Card["Basic Card"]
test/unit/card/rename_test.rb:    c.name="banana card"
test/unit/card/rename_test.rb:    c.save!
test/unit/card/rename_test.rb:    assert_equal 'banana_card', c.key
test/unit/card/rename_test.rb:    assert Card["Banana Card"] != nil
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  private
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def name_invariant_attributes( card )
test/unit/card/rename_test.rb:    {
test/unit/card/rename_test.rb:      :content => card.content,
test/unit/card/rename_test.rb:#      :writer => card.writer,
test/unit/card/rename_test.rb:      :revisions => card.revisions.length,
test/unit/card/rename_test.rb:      :referencers => card.referencers.map(&:name).sort,
test/unit/card/rename_test.rb:      :referencees => card.referencees.map(&:name).sort,
test/unit/card/rename_test.rb:      :dependents => card.dependents.length
test/unit/card/rename_test.rb:    }
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def assert_rename( card, new_name )
test/unit/card/rename_test.rb:    attrs_before = name_invariant_attributes( card )
test/unit/card/rename_test.rb:    card.name=new_name
test/unit/card/rename_test.rb:    card.update_referencers = true
test/unit/card/rename_test.rb:    card.save!
test/unit/card/rename_test.rb:    assert_equal attrs_before, name_invariant_attributes(card)
test/unit/card/rename_test.rb:    assert_equal new_name, card.name
test/unit/card/rename_test.rb:    assert Card[new_name]
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def card(name)
test/unit/card/rename_test.rb:    Card[name].refresh or raise "Couldn't find card named #{name}"
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_renaming_card_with_self_link_should_not_hang
test/unit/card/rename_test.rb:    c = Card["Dairy"]
test/unit/card/rename_test.rb:    c.name = "Buttah"
test/unit/card/rename_test.rb:    c.update_referencers = true
test/unit/card/rename_test.rb:    c.save!
test/unit/card/rename_test.rb:    assert_equal "[[/new/{{_self|name}}|new]]", Card["Buttah"].content
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_renaming_card_without_updating_references_should_not_have_errors
test/unit/card/rename_test.rb:    c = Card["Dairy"]
test/unit/card/rename_test.rb:    c.update_attributes "name"=>"Newt", "update_referencers"=>'false'
test/unit/card/rename_test.rb:    assert_equal "[[/new/{{_self|name}}|new]]", Card["Newt"].content
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_rename_should_not_fail_when_updating_inaccessible_referencer
test/unit/card/rename_test.rb:    Card.create! :name => "Joe Card", :content => "Whattup"
test/unit/card/rename_test.rb:    Account.as :joe_admin do
test/unit/card/rename_test.rb:      Card.create! :name => "Admin Card", :content => "[[Joe Card]]"
test/unit/card/rename_test.rb:    end
test/unit/card/rename_test.rb:    c = Card["Joe Card"]
test/unit/card/rename_test.rb:    c.update_attributes! :name => "Card of Joe", :update_referencers => true
test/unit/card/rename_test.rb:    assert_equal "[[Card of Joe]]", Card["Admin Card"].content
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:  def test_rename_should_not_fail_when_updating_hard_templated_referencer
test/unit/card/rename_test.rb:    c=Card.create! :name => "Pit"
test/unit/card/rename_test.rb:    Card.create! :name => "Orange", :type=>"Fruit", :content => "[[Pit]]"
test/unit/card/rename_test.rb:    Card["Fruit+*type+*default"].update_attributes(:content=>"this [[Pit]]")
test/unit/card/rename_test.rb:
test/unit/card/rename_test.rb:    assert_equal "this [[Pit]]", Card["Orange"].content
test/unit/card/rename_test.rb:    c.update_attributes! :name => "Seed", :update_referencers => true
test/unit/card/rename_test.rb:    assert true  # just make sure nothing exploded
test/unit/card/rename_test.rb:  end
test/unit/card/rename_test.rb:end
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
