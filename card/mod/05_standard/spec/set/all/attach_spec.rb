# -*- encoding : utf-8 -*-

describe Card::Set::All::Attach do
  it 'should be triggered by image card creation' do
    file = File.new("#{ Cardio.gem_root }/test/fixtures/mao2.jpg")
    card = Card.create :name => "Bananamaster", :type=>'Image', :attach=>file
    expect(card.attach.url).to match(/^\/files\/Bananamaster-original-\d+/)
  end
end
