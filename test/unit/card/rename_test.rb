require File.dirname(__FILE__) + '/../../test_helper'
class Card::RenameTest < Test::Unit::TestCase
  common_fixtures

  def setup
    setup_default_user
  end

  def test_flip
    with_debugging do
      assert_rename card("A+B"), "B+A"
    end
  end

  def test_should_error_card_exists
    @t=card("T"); @t.name="A+B"; 
    assert !@t.save, "save should fail"
    assert @t.errors.on(:name), "should have errors on key"
  end

  def test_used_as_tag  
    @b=card("B"); @b.name='A+D'; @b.save
    assert @b.errors.on(:name)
  end

  
  def test_update_dependents
    c1 =   Card["One"]
    c12 =  Card["One+Two"]
    c123 = Card["One+Two+Three"]
    c41 =  Card["Four+One"]
    c415 = Card["Four+One+Five"]

    assert_equal ["One#{JOINT}Two","One#{JOINT}Two#{JOINT}Three","Four#{JOINT}One","Four#{JOINT}One#{JOINT}Five"], [c12,c123,c41,c415].plot(:name)
    c1.name="Uno"
    c1.confirm_rename = true
    c1.save!
    assert_equal ["Uno#{JOINT}Two","Uno#{JOINT}Two#{JOINT}Three","Four#{JOINT}Uno","Four#{JOINT}Uno#{JOINT}Five"], [c12,c123,c41,c415].plot(:reload).plot(:name)
  end     


  def test_junction_to_simple   
    assert_rename card("A+B"), "K" 
  end
   
  
  def test_should_error_invalid_name
    @t=card("T"); @t.name="YT_o~Yo"; @t.save
    assert @t.errors.on(:name)
  end  
  
  
  def test_simple_to_simple
    assert_rename card("A"), "Alephant"
  end
         
  def test_simple_to_junction_with_create
    assert_rename card("T"), "C+J"
  end

  def test_subdivision
    assert_rename card("A+B"), "A+B+T"  # re-uses the parent card: A+B
  end
  
  def test_reset_key
    c = Card["Basic Card"]
    c.name="banana card"
    c.save!
    assert_equal 'banana_card', c.key
    assert Card["Banana Card"] != nil
  end
  
  def test_update_permissions
    
  end


 
  private
  
  def with_debugging
    Card::Base.debug = true             
    yield
  ensure
    Card::Base.debug = nil
  end
  
  def name_invariant_attributes( card )
    {
      :content => card.content,
#      :writer => card.writer,
      :revisions => card.revisions.length,
      :referencers => card.referencers.plot(:name).sort,
      :referencees => card.referencees.plot(:name).sort,
      :extension => card.extension,
      :dependents => card.dependents.length
    }
  end
  
  def assert_rename( card, new_name )
    attrs_before = name_invariant_attributes( card )
    card.name=new_name
    card.confirm_rename = true
    card.save!
    assert_equal attrs_before, name_invariant_attributes(card)
    assert_equal new_name, card.name
    assert Card.find_by_name(new_name)
  end    
  
  def card(name)
    Card.find_by_name(name) or raise "Couldn't find card named #{name}"
  end                          

end

