require File.dirname(__FILE__) + '/../../test_helper'
class Card::RenameTest < Test::Unit::TestCase
  common_fixtures
  
  # FIXME: these tests are TOO SLOW!  8s against server, 12s from command line.  
  # not sure if it's the card creation or the actual renaming process.
  # Card#save needs optimized in general.
  
  def setup
    setup_default_user
  end
      
  def test_rename_name_substitution
    c1 = Card.create! :name => "chuck_wagn+chuck"
    c2 = Card["chuck"]
    assert_rename c2, "buck"
    assert_equal "chuck_wagn+buck", Card.find(c1.id).name
  end      
                                      
  def test_rename_same_key_with_dependents
    assert_rename card("B"), "b"
  end                                     

  def test_updates_inclusions_when_renaming    
    Card::Base.debug=true
    c1 = Card.create! :name => "Blue"
    c2 = Card.create! :name => "br1", :content => "{{Blue}}"
    c3 = Card.create! :name => "br2", :content => "{{blue|closed;other:stuff}}"
    
    #assert_equal ["br1","br2"], c1.transcluders.map(&:name).sort
    c1.reload.name = "Red"
    c1.confirm_rename = true
    c1.update_referencers = true
    c1.save!
    assert_equal "{{Red}}", Card.find(c2.id).content                     
    # NOTE these attrs pass through a hash stage that may not preserve order
    assert_equal "{{Red|closed;other:stuff}}", Card.find(c3.id).content  
  end

  
  def test_reference_updates_on_case_variants
    c1 = Card.create! :name => "Blue"
    c2 = Card.create! :name => "blue ref 1", :content => "[[Blue]]"
    c3 = Card.create! :name => "blue ref 2", :content => "[[blue]]"
    c1.reload.name = "Red"
    c1.confirm_rename = true
    c1.update_referencers = true
    c1.save!
    assert_equal "[[Red]]", Card.find(c2.id).content
    assert_equal "[[Red]]", Card.find(c3.id).content
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

    assert_equal ["One+Two","One+Two+Three","Four+One","Four+One+Five"], [c12,c123,c41,c415].plot(:name)
    c1.name="Uno"
    c1.confirm_rename = true
    c1.save!
    assert_equal ["Uno+Two","Uno+Two+Three","Four+Uno","Four+Uno+Five"], [c12,c123,c41,c415].plot(:reload).plot(:name)
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
    card.update_referencers = true
    card.confirm_rename = true
    card.save!
    assert_equal attrs_before, name_invariant_attributes(card)
    assert_equal new_name, card.name
    assert Card.find_by_name(new_name)
  end    
  
  def card(name)
    Card.find_by_name(name) or raise "Couldn't find card named #{name}"
  end                          

  def test_renaming_card_with_self_link_should_not_hang
    Card.create! :type=>"Cardtype", :name=>"Dairy", :content => "[[/new/{{_self|name}}|new]]"
    c = Card["Dairy"]
    c.name = "Buttah"
    c.update_referencers = true
    c.confirm_rename = true
    c.save!
    assert_equal "[[/new/{{_self|name}}|new]]", Card["Buttah"].content
  end

end

