# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::All::Initialize do
  describe "new" do
    it "handles explicit nil as parameters" do
      c = Card.new nil
      c.should be_instance_of(Card)
      c.name.should == ''
    end

    it "handles nil name" do
      c = Card.new :name => nil
      c.should be_instance_of(Card)
      c.name.should == ''
    end
    
    it 'handles legit name' do
      c = Card.new :name => 'Ceee'
      c.should be_instance_of(Card)
      c.name.should == 'Ceee'
    end    
  end
  
  
  describe "module inclusion" do
    context '(search)' do
      before do
        @c = Card.new :type=>'Search', :name=>'Module Inclusion Test Card'
      end

      it "happens after new" do
        @c.respond_to?( :get_spec ).should be_true
      end

      it "happens after save" do
        @c.respond_to?( :get_spec ).should be_true
        @c.save!
        @c.respond_to?( :get_spec ).should be_true
      end

      it "happens after fetch" do
        @c.save!
        c = Card.fetch(@c.name)
        c.respond_to?( :get_spec ).should be_true
      end
    end

    context '(pointer)' do
      it "happens with explicit pointer setting" do
        Card.new(:type=>'Pointer').respond_to?(:add_item).should be_true
      end

      it "happens with implicit pointer setting (from template)" do
        Card.new(:name=>'Home+*watchers').should be_true
      end
    end
  end
end
