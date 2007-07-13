require File.dirname(__FILE__) + '/../../test_helper'
class Card::RenameTest < Test::Unit::TestCase
  common_fixtures

  def setup
    setup_default_user
    @z = newcard("Z", "I'm here to be referenced to")
    @a = newcard("A", "Alpha [[Z]]")
    @b = newcard("B", "Beta {{Z}}")        
    @t = newcard("T", "Theta")
    @ab = @a.connect(@b, "AlphaBeta")
    # references
    @x = newcard("X", "[[A]] [[A+B]] [[T]]")
    @y = newcard("Y", "{{B}} {{A+B}} {{A}} {{T}}")   
  end

  def test_junction_to_simple   
    assert_rename @ab, "F" 
  end
   
  def test_used_as_tag
    assert_raises(Wagn::Oops) { @b.rename('A+D') }
  end
  
  def test_invalid_name   
    assert_raises(Wagn::Oops) { @t.rename("YT_o~Yo") }
  end  
  
  def test_card_exists
    assert_raises(Wagn::Oops) { @t.rename("A+B") }
  end
  
  def test_simple_to_simple
    assert_rename @a, "Alephant"
  end
         
  def test_simple_to_junction_with_create
    assert_rename @t, "C+J"
  end
  
 

  def test_subdivision
    assert_rename @ab, "A+B+T"  # re-uses the parent card: A+B
  end
  
  def test_flip
    assert_rename @ab, "B+A"
  end
   
  def test_update_permissions
    
  end

  def test_pickup_new_links
    @l = newcard("L", "[[A+B+C]]")
    @ab.rename("A+B+C")
    assert @ab.referencers.plot(:name).include?("L")
  end

  def test_update_references
     watermelon = newcard('watermelon', 'mmmm')
     seeds = newcard('seeds')
     watermelon_seeds = watermelon.connect! seeds, 'black'
     lew = newcard('Lew', "likes [[watermelon]] and [seeds][watermelon#{JOINT}seeds]")
     watermelon.rename( "grapefruit", update_links=true )
     assert_equal "likes [[grapefruit]] and [seeds][grapefruit#{JOINT}seeds]", lew.reload.content
     watermelon.rename( 'bananas', update_links=false)
     assert_equal "likes [[grapefruit]] and [seeds][grapefruit#{JOINT}seeds]", lew.reload.content 
   end

   def test_update_dependents
     # this test assume JOINT = '#{JOINT}'
     c1 =  newcard("One") 
     c2 =  newcard("Two") 
     c3 =  newcard("Three") 
     c4 =  newcard("Four")
     c5 =  newcard("Five")
     c6 =  newcard("Six")

     c12 = c1.connect c2
     c123 = c12.connect c3
     c41 = c4.connect c1
     c415 = c41.connect c5

     assert_equal ["One#{JOINT}Two","One#{JOINT}Two#{JOINT}Three","Four#{JOINT}One","Four#{JOINT}One#{JOINT}Five"], [c12,c123,c41,c415].plot(:name)
     c1.rename("Uno")
     assert_equal ["Uno#{JOINT}Two","Uno#{JOINT}Two#{JOINT}Three","Four#{JOINT}Uno","Four#{JOINT}Uno#{JOINT}Five"], [c12,c123,c41,c415].plot(:reload).plot(:name)
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
      :writer => card.writer,
      :revisions => card.revisions.length,
      :referencers => card.referencers.plot(:name).sort,
      :referencees => card.referencees.plot(:name).sort,
      :extension => card.extension,
      :dependents => card.dependents.length
    }
  end
  
  def assert_rename( card, new_name )
    attrs_before = name_invariant_attributes( card )
    card.rename(new_name)
    assert_equal attrs_before, name_invariant_attributes(card)
    assert_equal new_name, card.name
    assert Card.find_by_name(new_name)
  end

end

