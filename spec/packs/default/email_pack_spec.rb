require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require File.expand_path('../pack_spec_helper', File.dirname(__FILE__))

describe Wagn::Renderer::EmailHtml do
  it "should render full urls" do
    Wagn::Conf[:base_url] = 'http://www.fake.com'
    render_content('[[B]]', :format=>'email_html').should == '<a class="known-card" href="http://www.fake.com/B">B</a>'
  end

  it "should render missing included cards as blank" do
    render_content('{{strombooby}}', :format=>'email_html').should == ''
  end
end
