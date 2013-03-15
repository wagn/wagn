require File.expand_path('../../../../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../../../packs/pack_spec_helper', File.dirname(__FILE__))

describe Wagn::Set::All::Json, "JSON pack" do
  context "status view" do
    it "should handle real and virtual cards" do
      real_json = render_card( :status, { :name=>'T' }, :format=>'json' )
      JSON[real_json].should == {"key"=>"t","status"=>"real","id"=>Card['T'].id, 'url_key'=>'T'}
      virtual_json = render_card( :status, { :name=>'T+*self' }, :format=>'json' )
      JSON[virtual_json].should == {"key"=>"t+*self","status"=>"virtual",'url_key'=>'T+*self'}
    end
    
    it "should treat both unknown and unreadable cards as unknown" do
      Account.as Card::AnonID do
        unknown = Card.new :name=>'sump'
        unreadable = Card.new :name=>'kumq', :type=>'Fruit'
        
        unknown_json = Wagn::Renderer::Json.new(unknown)._render_status
        JSON[unknown_json].should == {"key"=>"sump","status"=>"unknown", 'url_key'=>'sump'}
        unreadable_json = Wagn::Renderer::Json.new(unreadable)._render_status
        JSON[unreadable_json].should == {"key"=>"kumq","status"=>"unknown", 'url_key'=>'kumq'}
      end
    end
  end
end
