# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Attach do
  it 'should be triggered by image card creation' do
    file = File.new("#{Rails.root}/test/fixtures/mao2.jpg")
    card = Card.create :name => "Bananamaster", :type=>'Image', :attach=>file
    card.attach.url.should =~ /^\/files\/Bananamaster-original-\d+/
  end
end
