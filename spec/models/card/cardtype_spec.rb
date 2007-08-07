require File.dirname(__FILE__) + '/../../spec_helper'

describe Card, "type" do
  @@ct = {}
  before do
    Cardtype.find(:all).plot(:class_name).map do |ct|
      @@ct[ct] = Card.const_get(ct).create :name=>"new #{ct}"
    end
  end
  
  Cardtype.find(:all).plot(:class_name).each do |ct|
    it "#{ct} should have editor_type" do
      @@ct[ct].editor_type.should_not be_nil
    end
  end
end