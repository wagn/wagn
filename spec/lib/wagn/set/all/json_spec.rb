require File.expand_path('../../../../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../../../packs/pack_spec_helper', File.dirname(__FILE__))

describe Wagn::Set::All::Json, "JSON pack" do
  context "status view" do
    it "should handle real and virtual cards" do
      render_card( :status, { :name=>'T' },       :format=>'json' ).should == %({"key":"t","status":"real","id":#{Card['T'].id}})
      render_card( :status, { :name=>'T+*self' }, :format=>'json' ).should == %({"key":"t+*self","status":"virtual"})
    end
    
    it "should treat both unknown and unreadable cards as unknown" do
      Account.as Card::AnonID do
        unknown = Card.new :name=>'sump'
        unreadable = Card.new :name=>'kumq', :type=>'Fruit'
        
        Wagn::Renderer::Json.new(unknown).   _render_status.should == %({"key":"sump","status":"unknown"})
        Wagn::Renderer::Json.new(unreadable)._render_status.should == %({"key":"kumq","status":"unknown"})
      end
    end
  end
end
