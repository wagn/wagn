# -*- encoding : utf-8 -*-

describe Card::EmailHtmlFormat do
  it "should render full urls" do
    Card::Env[:protocol] = 'http://'
    Card::Env[:host] = 'www.fake.com'
    render_content('[[B]]', :format=>'email_html').should == '<a class="known-card" href="http://www.fake.com/B">B</a>'
  end

  it "should render missing included cards as blank" do
    render_content('{{strombooby}}', :format=>'email_html').should == ''
  end
end
