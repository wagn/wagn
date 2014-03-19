# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Json, "JSON mod" do
  context "status view" do
    it "should handle real and virtual cards" do
      jf = Card::JsonFormat
      real_json = jf.new(Card['T']).show :view=>:status
      JSON[real_json].should == {"key"=>"t","status"=>"real","id"=>Card['T'].id, 'url_key'=>'T'}
      virtual_json = jf.new(Card.fetch('T+*self')).show :view=>:status
      JSON[virtual_json].should == {"key"=>"t+*self","status"=>"virtual",'url_key'=>'T+*self'}
    end
    
    it "should treat both unknown and unreadable cards as unknown" do
      Card::Auth.as Card::AnonID do
        jf = Card::JsonFormat
        
        unknown = Card.new :name=>'sump'
        unreadable = Card.new :name=>'kumq', :type=>'Fruit'
        unknown_json = jf.new(unknown).show :view=>:status
        JSON[unknown_json].should == {"key"=>"sump","status"=>"unknown", 'url_key'=>'sump'}
        unreadable_json = jf.new(unreadable).show :view=>:status
        JSON[unreadable_json].should == {"key"=>"kumq","status"=>"unknown", 'url_key'=>'kumq'}
      end
    end
  end
end
