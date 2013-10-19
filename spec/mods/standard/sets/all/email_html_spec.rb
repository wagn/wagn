# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::EmailHtmlFormat do
  it "should render full urls" do
    Wagn::Env[:protocol] = 'http://'
    Wagn::Env[:host] = 'www.fake.com'
    render_content('[[B]]', :format=>'email_html').should == '<a class="known-card" href="http://www.fake.com/B">B</a>'
  end

  it "should render missing included cards as blank" do
    render_content('{{strombooby}}', :format=>'email_html').should == ''
  end
end
