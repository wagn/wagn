require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class LinkTest < Test::Unit::TestCase
  test_helper :chunk
  common_fixtures
  def setup
    setup_default_user
  end
  
  def test_basic
    card = newcard('Baines', '[[Nixon]]')
    assert_equal('<a class="wanted-card" href="/wagn/Nixon">Nixon</a>', render(card) )

    card2 = newcard('Johnson', '[Lyndon][Baines]')
    assert_equal('<a class="known-card" href="/wagn/Baines">Lyndon</a>', render(card2) )
  end
     
  def test_semi_relative
    card3 = newcard('recent changes', '[[/recent]]')
    assert_equal('<a class="internal-link" href="/recent">/recent</a>', render(card3), "internal link-- KNOWN TO BE BROKEN" )
  end
  
  def test_external
    card4 = newcard('google link', '[[http://google.com]]')
    assert_equal('<a class="external-link" href="http://google.com">http://google.com</a>', render(card4) )   
  end
  
  def internal_needs_escaping    
    card5 = newcard('userlink', '[Marie][Marie "Mad Dog" Deatherage]')
    assert_equal('<a class="wanted-card" href="/wagn/Marie_%22Mad_Dog%22_Deatherage">Marie</a>', render(card5) )
  end
     
  def external_needs_not_escaped
    card6 = newcard('google link2', 'wgw&nbsp; [google][http://www.google.com] &nbsp;  <br>')
    assert_equal "wgw&nbsp; <a class=\"wanted-card\" href=\"http://www.google.com\">google</a> &nbsp;  <br>", render(card6)
  end
  
  def test_relative_link
    dude,job = newcard('Harvey',"[[#{JOINT}business]]"), newcard('business')
    card = dude.connect job, "icepicker" 
    assert_equal("<a class=\"known-card\" href=\"/wagn/Harvey%2Bbusiness\">#{JOINT}business</a>", render(dude) )
  end
  
  
  
  
end                                                                      
  
