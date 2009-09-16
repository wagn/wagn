require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class LinkTest < ActiveSupport::TestCase
  include ChunkTestHelper
  
  def setup
    setup_default_user
  end
  
  def test_basic
    card = newcard('Baines', '[[Nixon]]')
    assert_equal('<a class="wanted-card" href="/wagn/Nixon">Nixon</a>', render(card) )


    lbj_link = '<a class="known-card" href="/wagn/Baines">Lyndon</a>'
    
    card2 = newcard('Johnson', '[Lyndon][Baines]')
    assert_equal(lbj_link, render(card2) )
    
    card2.content = '[[Baines|Lyndon]]'; card2.save
    assert_equal(lbj_link, render(card2) )
    
  end

  def test_relative_card
    cardA = newcard('Kennedy', '[[+Monroe]]')
    assert_equal('<a class="wanted-card" href="/wagn/Kennedy%2BMonroe">+Monroe</a>', render(cardA) )

    cardB = newcard('Clinton', '[[Lewinsky+]]')
    assert_equal('<a class="wanted-card" href="/wagn/Lewinsky%2BClinton">Lewinsky+</a>', render(cardB) )
  end


     
  def test_relative_url
    card3 = newcard('recent changes', '[[/recent]]')
    assert_equal('<a class="internal-link" href="/recent">/recent</a>', render(card3) )
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
    dr = render(dude)
ActiveRecord::Base.logger.info("DudeR:#{dr}\n")
    assert_equal("<a class=\"known-card\" href=\"/wagn/Harvey+business\">#{JOINT}business</a>", dr )
  end
  
  
  
  
end                                                                      
  
