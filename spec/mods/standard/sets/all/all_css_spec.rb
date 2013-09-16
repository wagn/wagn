# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::AllCss do
  it "should render content view" do
    content = '#box { display: block }'
    rendered = render_card :content, { :content=>content }, :format=>:css
    rendered.should =~ /Style Card\:/
    rendered.should =~ /#{ Regexp.escape content }/
  end
end
