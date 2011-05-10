require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../pack_spec_helper'

describe EmailHtmlRenderer do
  it "should render full urls" do
    System.base_url = 'http://www.fake.com'
    render_content('[[B]]', :format=>'email_html').should == '<a class="known-card" href="http://www.fake.com/wagn/B">B</a>'
  end
  
  it "should render missing included cards as blank" do
    render_content('{{strombooby}}', :format=>'email_html').should == ''
  end
end