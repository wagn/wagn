require File.expand_path('../../test_helper', File.dirname(__FILE__))

class LinkTest < ActiveSupport::TestCase
  include ChunkTestHelper
  
  def setup
    super
    setup_default_user
  end
  
  def test_basic
    card = newcard('Baines', '[[Nixon]]')
    assert_equal('<a class="wanted-card" href="/Nixon">Nixon</a>', render_test_card(card) )


    lbj_link = '<a class="known-card" href="/Baines">Lyndon</a>'
    
    card2 = newcard('Johnson', '[Lyndon][Baines]')
    assert_equal(lbj_link, render_test_card(card2) )
    
    card2.content = '[[Baines|Lyndon]]'; card2.save
    assert_equal(lbj_link, render_test_card(card2) )
    
  end

  def test_relative_card
    cardA = newcard('Kennedy', '[[+Monroe]]')
    assert_equal('<a class="wanted-card" href="/Kennedy%2BMonroe">+Monroe</a>', render_test_card(cardA) )

    cardB = newcard('Clinton', '[[Lewinsky+]]')
    assert_equal('<a class="wanted-card" href="/Lewinsky%2BClinton">Lewinsky</a>', render_test_card(cardB) )
  end


     
  def test_relative_url
    card3 = newcard('recent changes', '[[/recent]]')
    assert_equal('<a class="internal-link" href="/recent">/recent</a>', render_test_card(card3) )
  end
  
  def test_external
    card4 = newcard('google link', '[[http://google.com]]')
    assert_equal('<a class="external-link" href="http://google.com">http://google.com</a>', render_test_card(card4) )   
  end
  
  def internal_needs_escaping    
    card5 = newcard('userlink', '[Marie][Marie "Mad Dog" Deatherage]')
    assert_equal('<a class="wanted-card" href="/Marie_%22Mad_Dog%22_Deatherage">Marie</a>', render_test_card(card5) )
  end
     
  def external_needs_not_escaped
    card6 = newcard('google link2', 'wgw&nbsp; [google][http://www.google.com] &nbsp;  <br>')
    assert_equal "wgw&nbsp; <a class=\"wanted-card\" href=\"http://www.google.com\">google</a> &nbsp;  <br>", render_test_card(card6)
  end
  
  def test_relative_link
    dude,job = newcard('Harvey',"[[#{SmartName.joint}business]]"), newcard('business')
    card = Card.create! :name => "#{dude.name}+#{job.name}", :content => "icepicker" 
    assert_equal("<a class=\"known-card\" href=\"/Harvey+business\">#{SmartName.joint}business</a>", render_test_card(dude) )
  end
  
  
  
  
end                                                                      
  
