require File.dirname(__FILE__) + '/../test_helper'

require_dependency 'wql.rb'
class WqlTest < Test::Unit::TestCase
  common_fixtures
  test_helper :wql

  def setup
    setup_default_user
  end
  
  def test_type_queries
    assert_wql( "basic cards", "cards with type='Basic' order by name" ) { Card.find_all_by_type_and_trash('Basic',false, :order=>'name') }
  end

  def test_parser
    p = Wql::Parser.new
    assert p.parse( "cards" )
    assert p.parse( "cards with name='blah'" )
    assert p.parse( "cards with name='blah' and (value='foo' or content='foo')" )
    assert p.parse( "cards tagged by cards with name='blah'" )
    assert p.parse( "cards with name='blah' and tagging cards with content='blorg'" )
    assert p.parse( "cards with name='blah' order by name" )
    assert p.parse( "cards with name='blah' order by name, id" )
  end
  
  def test_card_queries
    assert_card_wql( "cousins", "cards tags are cards with id={id} order by name" ) {|c| c.left_junctions_for_test }
    assert_card_wql( "children", "cards trunks are cards with id={id} order by name") {|c| c.right_junctions_for_test }
    assert_card_wql( "relatives", "cards plus cards with id={id} order by name") {|c| c.junctions_for_test }
    assert_card_wql( "pieces", "pieces of cards with id={id}") {|c| c.pieces_for_test }
  end                                 
  
  def test_common_cards
    assert_wql("common tags", "cards tagging cards with type='Basic' order by cards_tagged desc limit 25")
    # containership works differently now-- label not longer applies ( I think )
    #assert_wql("containers?","cards with trunk_id=15269 and tags are cards with label=#{System.connection.quote(true)}")
    assert_wql("sidebar1","cards tagged by cards with name='*sidebar'")
    assert_wql("sidebar2", "cards with trunk_id=33 and tags are cards tagged by cards with name='*sidebar'")
  end
  
  def test_find_by_wql_options
    assert Card.find_by_wql_options( :type=>'Cardtype' )
    assert Card.find_by_wql_options( :keyword=>'foo' )
    assert Card.find_by_wql_options( :type=>'Cardtype', :keyword=>'foo' )
    assert Card.find_by_wql_options( :type=>'Cardtype', :keyword=>'' )
    assert Card.find_by_wql_options( :type=>'', :keyword=>'foo' )
  end
    
  def test_tagging
    assert_equal %w(B C D E), Card.find_by_wql("cards tagging cards where name='A' order by name").plot(:name)    
  end
  
  def test_tagged_by
    assert_equal %w(C D F), Card.find_by_wql("cards tagged by cards where name='A' order by name").plot(:name)    
  end

  def test_connected_to
    assert_equal %w(B C D E F), Card.find_by_wql("cards connected to cards where name='A' order by name").plot(:name)
    # make sure it works with or without a closing order or limit    
    assert_equal %w(B C D E F), Card.find_by_wql("cards connected to cards where name='A'").plot(:name).sort    
  end
        
  def test_options  
    assert_equal %w(A B C D E Five One Three Two), Card.find_by_wql_options({:tagging=>{:type=>"Basic"}}).plot(:name).sort
    %w( A B C ).each do |c|  Card.find_by_name(c).destroy! end
    assert_equal %w( Five One Three Two), Card.find_by_wql_options({:tagging=>{:type=>"Basic"}}).plot(:name).sort
  end  
  
  def test_tag_cloud
    assert_equal %w(A B C D E Five One Three Two), Card.find_by_wql("cards tagging cards where type='Basic' order by cards_tagged").plot(:name).sort
  end


  private
  
  def assert_wql( test_name, wql )
    if block_given?
      # check that it matches the output of the block
      assert_equal yield.plot(:name), Card.find_by_wql(wql).plot(:name), test_name
    else
      # just check that the sql doesn't break
      assert Card.find_by_wql( wql )
    end
  end
  
  def assert_card_wql( test_name, wql )
    Card::Base.find(:all).each do |c|
      local_wql = wql.gsub(/\{id\}/, c.id.to_s)
      assert_equal yield(c).plot(:name), Card.find_by_wql( local_wql ).plot(:name), "#{test_name}: #{local_wql}"
    end
  end
  
end
