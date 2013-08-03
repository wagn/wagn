# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Right::Structure do
  it "closed_content is rendered as title + raw" do
    template = Card.new(:name=>'A+*right+*structure', :content=>'[[link]] {{inclusion}}')
    Card::Format.new(template)._render(:closed_content).should ==
      '<a href="/Basic" class="cardtype default-type">Basic</a> : [[link]] {{inclusion}}'
  end
end
