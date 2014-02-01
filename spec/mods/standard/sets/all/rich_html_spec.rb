# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::RichHtml do
  context :missing do
    it "should prompt to add" do
      render_content('{{+cardipoo|open}}').match(/Add \<span/ ).should_not be_nil
    end
  end
  context "type_list" do
    before do
      @card = Card['UserForm']  # no cards with this type
    end
    it "should get type options from type_field renderer method" do
      Card::HtmlFormat.new(@card).type_field.should match(/<option [^>]*selected/)
      tf=Card::HtmlFormat.new(@card).type_field(:no_current_type=>true)
      tf.should_not match(/<option [^>]*selected/)
      tf.scan(/<option /).length.should == 23
    end
    it "should get type list" do
      Account.as :anonymous do
        tf=Card::HtmlFormat.new(@card).type_field(:no_current_type=>true)
        tf.should_not match(/<option [^>]*selected/)
        tf.scan(/<option /).length.should == 1
        tf=Card::HtmlFormat.new(@card).type_field
        tf.should match(/<option [^>]*selected/)
        tf.scan(/<option /).length.should == 2
      end
    end
  end
  context "type and header" do
    before do
      @card = Card['UserForm']  # no cards with this type
    end
    it "should render type header without type link by default" do
      Card::HtmlFormat.new(@card).render_header.should_not match(/<a [^>]* class="([^"]* )?cardtype[^"]*"/)
    end
    it "should render type header with type link controlled by wagneer option with developer option on" do
      Card::HtmlFormat.new(@card).render_header(:with_type=>true).should match(/<a [^>]* class="([^"]* )?cardtype[^"]*"/)
      Card::HtmlFormat.new(@card).render_header(:with_type=>true,:hide=>'type').should_not match(/<a [^>]* class="([^"]* )?cardtype[^"]*"/)
    end
    it "should render type header without no-edit class when no cards of type (new)" do
      Card::HtmlFormat.new(@card).render_header(:with_type=>true).should_not match(/<a [^>]* class="([^"]* )?no-edit[^"]*"/)
    end
    it "should render type header with no-edit class when no cards of type (new)" do
      no_edit_card = Card['cardtype a']
      Card::HtmlFormat.new(no_edit_card).render_header(:with_type=>true).should match(/<a [^>]* class="([^"]* )?no-edit[^"]*"/)
    end
  end
end
