require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require File.expand_path('../pack_spec_helper', File.dirname(__FILE__))
include PackSpecHelper
#~~~~~~~~~ ERROR HANDLING

describe Wagn::Renderer do
  it "should render deny_view when user lacks read permissions" do
    c = Card.fetch('Administrator links')
    c.who_can(:read).should == ['administrator']
    User.as(:anon) do
      c.ok?(:read).should == false
      render_card(:core, c).match('denied').should_not be_nil

    end
  end
end
