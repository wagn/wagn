require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Card::RenameTest < ActiveSupport::TestCase


  # FIXME: these tests are TOO SLOW!  8s against server, 12s from command line.
  # not sure if it's the card creation or the actual renaming process.
  # Card#save needs optimized in general.
  def self.add_test_data
  end

  def setup
    super
    Session.as_bot do
     Card.create! :name => "chuck_wagn+chuck"
     Card.create! :name => "Blue"
     
     Card.create! :name => "blue includer 1", :content => "{{Blue}}"
     Card.create! :name => "blue includer 2", :content => "{{blue|closed;other:stuff}}"
     
     Card.create! :name => "blue linker 1", :content => "[[Blue]]"
     Card.create! :name => "blue linker 2", :content => "[[blue]]"
     
     Card.create! :type=>"Cardtype", :name=>"Dairy", :content => "[[/new/{{_self|name}}|new]]"
     
     c3, c4 = Card["chuck_wagn+chuck"], Card["chuck"]
     Rails.logger.info "testing point 0 #{c3.right}, #{c3}, #{c4}"
    end
    setup_default_user
    super
  end

  def test_subdivision
    assert_rename card("A+B"), "A+B+T"  # re-uses the parent card: A+B
  end

<<<<<<< HEAD
=======

>>>>>>> develop
  def test_rename_name_substitution
    c1, c2 = Card["chuck_wagn+chuck"], Card["chuck"]
    Rails.logger.info "testing point #{c1}, #{c2}"
    assert_rename c2, "buck"
    assert_equal "chuck_wagn+buck", Card.find(c1.id).name
  end

  def test_rename_same_key_with_dependents
    assert_rename card("B"), "b"
  end

  def test_junction_to_simple
    assert_rename card("A+B"), "K"
  end

  def test_reference_updates_plus_to_simple
     c1, c2 = Card['Blue'], Card["chuck_wagn+chuck"]
     c1.content = "[[chuck wagn+chuck]]"
     c1.save!
     assert_rename c2, 'schmuck'
     assert_equal '[[schmuck]]', Card.find(c1.id).content
  end

  def test_updates_inclusions_when_renaming
    c1,c2,c3 = Card["Blue"], Card["blue includer 1"], Card["blue includer 2"]
    c1.update_attributes :name => "Red", :update_referencers => true
    assert_equal "{{Red}}", Card.find(c2.id).content                     
    # NOTE these attrs pass through a hash stage that may not preserve order
    assert_equal "{{Red|closed;other:stuff}}", Card.find(c3.id).content
  end

  def test_updates_inclusions_when_renaming_to_plus
    c1,c2 = Card["Blue"], Card["blue includer 1"]
    c1.update_attributes :name => "blue includer 1+color", :update_referencers => true
    assert_equal "{{blue includer 1+color}}", Card.find(c2.id).content                     
  end

  def test_reference_updates_on_case_variants
    c1,c2,c3 = Card["Blue"], Card["blue linker 1"], Card["blue linker 2"]
    c1.reload.name = "Red"
    c1.update_referencers = true
    c1.save!
    assert_equal "[[Red]]", Card.find(c2.id).content
    assert_equal "[[Red]]", Card.find(c3.id).content
  end

  def test_flip
    assert_rename card("A+B"), "B+A"
  end

  def test_should_error_card_exists
    @t=card("T"); @t.name="A+B";
    assert !@t.save, "save should fail"
    assert @t.errors[:name], "should have errors on key"
  end

  def test_used_as_tag
    @b=card("B"); @b.name='A+D'; @b.save
    assert @b.errors[:name]
  end

  def test_update_dependents
    c1 =   Card["One"]
    c12 =  Card["One+Two"]
    c123 = Card["One+Two+Three"]
    c41 =  Card["Four+One"]
    c415 = Card["Four+One+Five"]

    assert_equal ["One+Two","One+Two+Three","Four+One","Four+One+Five"], [c12,c123,c41,c415].plot(:name)
    c1.name="Uno"
    c1.save!
    assert_equal ["Uno+Two","Uno+Two+Three","Four+Uno","Four+Uno+Five"], [c12,c123,c41,c415].plot(:reload).plot(:name)
  end

  def test_should_error_invalid_name
    @t=card("T"); @t.name="YT_o~Yo"; @t.save
    assert @t.errors[:name]
  end

  def test_simple_to_simple
    assert_rename card("A"), "Alephant"
  end

  def test_simple_to_junction_with_create
    assert_rename card("T"), "C+J"
  end

  def test_reset_key
    c = Card["Basic Card"]
    c.name="banana card"
    c.save!
    assert_equal 'banana_card', c.key
    assert Card["Banana Card"] != nil
  end

  private

  def name_invariant_attributes( card )
    {
      :content => card.content,
#      :writer => card.writer,
      :revisions => card.revisions.length,
      :referencers => card.referencers.plot(:name).sort,
      :referencees => card.referencees.plot(:name).sort,
      :dependents => card.dependents.length
    }
  end

  def assert_rename( card, new_name )
    attrs_before = name_invariant_attributes( card )
    card.name=new_name
    card.update_referencers = true
    card.save!
    assert_equal attrs_before, name_invariant_attributes(card)
    assert_equal new_name, card.name
    assert Card[new_name]
  end

  def card(name)
    Card[name].refresh or raise "Couldn't find card named #{name}"
  end

  def test_renaming_card_with_self_link_should_not_hang
    c = Card["Dairy"]
    c.name = "Buttah"
    c.update_referencers = true
    c.save!
    assert_equal "[[/new/{{_self|name}}|new]]", Card["Buttah"].content
  end

  def test_renaming_card_without_updating_references_should_not_have_errors
    c = Card["Dairy"]
    c.update_attributes "name"=>"Newt", "update_referencers"=>'false'
    assert_equal "[[/new/{{_self|name}}|new]]", Card["Newt"].content
  end

  def test_rename_should_not_fail_when_updating_inaccessible_referencer
    Card.create! :name => "Joe Card", :content => "Whattup"
    Session.as :joe_admin do
      Card.create! :name => "Admin Card", :content => "[[Joe Card]]"
    end
    c = Card["Joe Card"]
    c.update_attributes! :name => "Card of Joe", :update_referencers => true
    assert_equal "[[Card of Joe]]", Card["Admin Card"].content
  end

  def test_rename_should_not_fail_when_updating_hard_templated_referencer
    c=Card.create! :name => "Pit"
    Card.create! :name => "Orange", :type=>"Fruit", :content => "[[Pit]]"
    Card["Fruit+*type+*default"].update_attributes(:content=>"this [[Pit]]")

    assert_equal "this [[Pit]]", Card["Orange"].content
    c.update_attributes! :name => "Seed", :update_referencers => true
    assert true  # just make sure nothing exploded
  end
end
