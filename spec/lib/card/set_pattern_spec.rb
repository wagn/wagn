# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

module SetPatternSpecHelper
  def it_generates( opts )
    name = opts[:name]
    card = opts[:from]
    it "generates name '#{name}' for card '#{card.name}'" do
      described_class.new(card).to_s.should == name
    end
  end
end

include SetPatternSpecHelper

describe Card::SetPattern do
end

#FIXME - these should probably be in pattern-specific specs, though that may not leave much to test in the base class :)

describe Card::SetPattern::RightPattern do
  it_generates :name => "author+*right", :from => Card.new( :name => "Iliad+author" )
  it_generates :name => "author+*right", :from => Card.new( :name => "+author" )
end

describe Card::SetPattern::TypePattern do
  it_generates :name => "Book+*type", :from => Card.new( :type => "Book" )
end

describe Card::SetPattern::AllPlusPattern do
  it_generates :name => "*all plus", :from => Card.new( :name => "Book+author" )
end

describe Card::SetPattern::AllPattern do
  it_generates :name => "*all", :from => Card.new( :type => "Book" )
end

describe Card::SetPattern::TypePlusRightPattern do
  it_generates :name => "Book+author+*type plus right", :from => Card.new( :name=>"Iliad+author" )
end