require File.expand_path('../test_helper', File.dirname(__FILE__))

#
# Note that we are using stub rendering here to get links.  This isn't really a very good
# test because it has a very special code path that is really very limited.  It gets
# internal links expanded in html or xml style, and prety much ignores any other output.
#
class Wagn::RendererTest < ActiveSupport::TestCase
  include ChunkTestHelper
  
  #attr_accessor :controller

  def setup
    setup_default_user     
  end

  def test_replace_references_should_work_on_inclusions_inside_links       
    card = Card.create!(:name=>"test", :content=>"[[test{{test}}]]"  )    
    assert_equal "[[test{{best}}]]", Wagn::Renderer.new(card).replace_references( "test", "best" )
  end

  def controller
    return @controller if @controller
    @controller = CardController.new()
#raise "App controller not created" unless @controller
    @controller
  end

  def slot_link card, format=:html
    renderer = Wagn::Renderer.new card, :format=>format
    renderer.add_name_context
    Rails.logger.warn "slat lk #{card.name},#{renderer}, #{format}"
    result = renderer.render :content
    m = result.match(/<(cardlink|link|a) class.*<\/(cardlink|link|a)>/)
    (m.to_s != "") ? m.to_s : result
  end

  def test_slot_render
    card = newcard('Baines', '[[Nixon]]')
    assert_equal '<a class="wanted-card" href="/Nixon">Nixon</a>', slot_link(card)

    lbj_link = '<a class="known-card" href="/Baines">Lyndon</a>'
    
    card2 = newcard('Johnson', '[Lyndon][Baines]')
    assert_equal(lbj_link, slot_link(card2))
    
    card2.content = '[[Baines|Lyndon]]'; card2.save
    assert_equal(lbj_link, slot_link(card2))
    
  end

  def test_slot_render_xml
    card = newcard('Baines', '[[Nixon]]')
    assert_equal %{<cardlink class="wanted-card" card="/Nixon">Nixon</cardlink>}, slot_link(card,:xml)

    card2 = newcard('Johnson', '[Lyndon][Baines]')
    lbj_link = %{<cardlink class=\"known-card\" card=\"/Baines\">Lyndon</cardlink>}
    assert_equal(lbj_link, slot_link(card2,:xml))
    
    card2.content = '[[Baines|Lyndon]]'; card2.save
    assert_equal(lbj_link, slot_link(card2,:xml))
    
  end

  def test_slot_relative_card
    cardA = newcard('Kennedy', '[[+Monroe]]')
    assert_equal '<a class="wanted-card" href="/Kennedy%2BMonroe">+Monroe</a>', slot_link(cardA)

    cardB = newcard('Clinton', '[[Lewinsky+]]')
    assert_equal '<a class="wanted-card" href="/Lewinsky%2BClinton">Lewinsky</a>', slot_link(cardB)
  end

  def test_slot_relative_card_xml
    cardA = newcard('Kennedy', '[[+Monroe]]')
    assert_equal %{<cardlink class="wanted-card" card="/Kennedy%2BMonroe">+Monroe</cardlink>}, slot_link(cardA,:xml)

    cardB = newcard('Clinton', '[[Lewinsky+]]')
    assert_equal %{<cardlink class="wanted-card" card="/Lewinsky%2BClinton">Lewinsky+</cardlink>}, slot_link(cardB,:xml)
  end

  def test_slot_relative_url
    card3 = newcard('recent changes', '[[/recent|Recent]]')
    assert_equal '<a class="internal-link" href="/recent">Recent</a>', slot_link(card3)
    card3 = newcard('rc2', '[[/recent]]')
  end
  
  def test_slot_external
    card4 = newcard('google link', '[[http://google.com]]')
    assert_equal '<a class="external-link" href="http://google.com">http://google.com</a>', slot_link(card4)
  end
  
  def test_slot_external_xml
    card4 = newcard('google link', '[[http://google.com]]')
    assert_equal '<link class="external-link" href="http://google.com">http://google.com</link>', slot_link(card4,:xml)
  end
  
  def internal_needs_escaping    
    card5 = newcard('userlink', '[Marie][Marie "Mad Dog" Deatherage]')
    assert_equal '<a class="wanted-card" href="/Marie_%22Mad_Dog%22_Deatherage">Marie</a>', slot_link(card5)
  end
     
  def external_needs_not_escaped
    card6 = newcard('google link2', 'wgw&nbsp; [google][http://www.google.com] &nbsp;  <br>')
    assert_equal "wgw&nbsp; <a class=\"wanted-card\" href=\"http://www.google.com\">google</a> &nbsp;  <br>", slot_link(card6)
  end
  
#  def test_relative_link
#    dude,job = newcard('Harvey',"[[#{JOINT}business]]"), newcard('business')
#ActionController::Base.logger.info("ERROR:INFO:newcard is nil: Harvey") unless dude
#ActionController::Base.logger.info("ERROR:INFO:newcard is nil: +business") unless job
#    card = dude.connect job, "icepicker" 
#ActionController::Base.logger.info("ERROR:INFO:newcard is nil: Harvey+business") unless card
#    assert_equal "<a class=\"known-card\" href=\"/Harvey+business\">#{JOINT}business</a>", slot_link(dude)
#  end
  
#  def test_relative_link_xml
#    dude,job = newcard('Harvey',"[[#{JOINT}business]]"), newcard('business')
#    card = dude.connect job, "icepicker" 
#    assert_equal "<cardref class=\"known-card\" card=\"Harvey+business\">#{JOINT}business</cardref>", slot_link(dude,:xml)
#  end
end                                                                      
