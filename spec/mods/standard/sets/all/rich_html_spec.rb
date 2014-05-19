# -*- encoding : utf-8 -*-

describe Card::Set::All::RichHtml do
  describe 'missing view' do
    it "should prompt to add" do
      render_content('{{+cardipoo|open}}').match(/Add \<span/ ).should_not be_nil
    end
  end
  
  describe "type_list" do
    before do
      @card = Card['UserForm']  # no cards with this type
    end
    
    it "should get type options from type_field renderer method" do
      @card.format.type_field.should match(/<option [^>]*selected/)
      tf=@card.format.type_field(:no_current_type=>true)
      tf.should_not match(/<option [^>]*selected/)
      tf.scan(/<option /).length.should == 25
      tf=@card.format.type_field
      tf.should match(/<option [^>]*selected/)
      tf.scan(/<option /).length.should == 25
    end
    
    it "should get type list" do
      Card::Auth.as :anonymous do
        tf=@card.format.type_field(:no_current_type=>true)
        tf.should_not match(/<option [^>]*selected/)
        tf.scan(/<option /).length.should == 1
        tf=@card.format.type_field
        tf.should match(/<option [^>]*selected/)
        tf.scan(/<option /).length.should == 2
      end
    end
  end
  
  context "type and header" do
    it "should render type without no-edit class when no cards of type" do
      card = Card['UserForm']  # no cards with this type
      card.format.render_type.should match(/<a [^>]* class="([^"]* )?cardtype[^"]*"/)
      card.format.render_type.should_not match(/<a [^>]* class="([^"]* )?no-edit[^"]*"/)
    end
    it "should render type header with no-edit class when cards of type exist" do
      no_edit_card = Card['cardtype a']
      no_edit_card.format.render_type.should match(/<a [^>]* class="([^"]* )?cardtype[^"]*"/)
      no_edit_card.format.render_type.should match(/<a [^>]* class="([^"]* )?no-edit[^"]*"/)
    end
  end
end
