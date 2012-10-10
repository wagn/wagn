require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Card::RemoveTest < ActiveSupport::TestCase
  

  def setup
    super
    setup_default_user
    @a = Card["A"]
  end

     
  # I believe this is here to test a bug where cards with certain kinds of references
  # would fail to delete.  probably less of an issue now that delete is done through
  # trash.  
  def test_remove
    assert @a.destroy!, "card should be destroyable"
    assert_nil Card["A"]
  end
         
  def test_recreate_plus_card_name_variant
    Card.create( :name => "rta+rtb" ).destroy
    Card["rta"].update_attributes :name=> "rta!"
    c = Card.create! :name=>"rta!+rtb"
    assert Card["rta!+rtb"]
    assert !Card["rta!+rtb"].trash
    assert Card.find_by_key('rtb*trash').nil?  
end   
  
  def test_multiple_trash_collision
    Card.create( :name => "alpha" ).destroy
    3.times do
      b = Card.create( :name => "beta" )
      b.name = "alpha"
      assert b.save! 
      b.destroy
    end
  end
  
end

