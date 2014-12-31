# -*- encoding : utf-8 -*-

describe Card::Set::Type::Uri do
  it "should have special editor" do
    assert_view_select render_editor('Uri'), 'input[type="text"][class="card-content"]'
  end

  it "renders core view links" do
    card = Card.create(:type=>'URI', :name=>'A URI card', :content=>'http://wagn.org/Home')
    assert_view_select card.format.render('core'), 'a[class="external-link"][href="http://wagn.org/Home"]' do
      assert_select 'span[class="card-title"]', {:text => 'A URI card' }
    end
  end

  it "renders core view links with title arg" do
    card = Card.create(:type=>'URI', :name=>'A URI card', :content=>'http://wagn.org/Home')
    assert_view_select card.format.render('core', :title=>'My Title'), 'a[class="external-link"][href="http://wagn.org/Home"]' do
      assert_select 'span[class="card-title"]', {:text => 'My Title' }
    end
  end

  it "renders a uri view" do
    card = Card.create(:type=>'URI', :name=>'A URI card', :content=>'http://wagn.org/Home')
    assert_view_select card.format.render('uri'), 'a[class="external-link"]', {:text => 'http://wagn.org/Home'}
  end
end
