# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Json, "JSON pack" do
  context "status view" do
    it "should handle real and virtual cards" do
      r = Card::JsonFormat
      real_json = r.new(Card['T'])._render_show :view=>:status
      JSON[real_json].should == {"key"=>"t","status"=>"real","id"=>Card['T'].id, 'url_key'=>'T'}
      virtual_json = r.new(Card.fetch('T+*self'))._render_show :view=>:status
      JSON[virtual_json].should == {"key"=>"t+*self","status"=>"virtual",'url_key'=>'T+*self'}
    end
    
    it "should treat both unknown and unreadable cards as unknown" do
      Account.as Card::AnonID do
        r = Card::JsonFormat
        
        unknown = Card.new :name=>'sump'
        unreadable = Card.new :name=>'kumq', :type=>'Fruit'
        unknown_json = r.new(unknown)._render_show :view=>:status
        JSON[unknown_json].should == {"key"=>"sump","status"=>"unknown", 'url_key'=>'sump'}
        unreadable_json = r.new(unreadable)._render_show :view=>:status
        JSON[unreadable_json].should == {"key"=>"kumq","status"=>"unknown", 'url_key'=>'kumq'}
      end
    end
  end
end
