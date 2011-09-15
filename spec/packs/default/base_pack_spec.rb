require_relative '../../spec_helper'
require_relative '../pack_spec_helper'

#~~~~~~~~~ ERROR HANDLING

describe Wagn::Renderer do
  it "should render deny_view when user lacks read permissions" do
    c = Card.fetch('Administrator links')
    c.who_can(:read).should == ['administrator']
    User.as(:anon) do
      c.ok?(:read).should == false
      render_card(:naked, c).match('denied').should_not be_nil

    end
  end
end
