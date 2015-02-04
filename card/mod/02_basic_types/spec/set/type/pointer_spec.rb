# -*- encoding : utf-8 -*-
describe Card::Set::Type::Pointer do
  describe "item_names" do
    it "should return array of names of items referred to by a pointer" do
      Card.new(:type=>'Pointer', :content=>"[[Busy]]\n[[Body]]").item_names.should == ['Busy', 'Body']
    end
  end

  describe "add_item" do
    it "add to empty ref list" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>""
      pointer.add_item "John"
      pointer.content.should == "[[John]]"
    end

    it "add to existing ref list" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      pointer.add_item "John"
      pointer.content.should == "[[Jane]]\n[[John]]"
    end

    it "not add duplicate entries" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      pointer.add_item "Jane"
      pointer.content.should == "[[Jane]]"
    end
  end

  describe "drop_item" do
    it "remove the link" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      pointer.drop_item "Jane"
      pointer.content.should == "[[John]]"
    end

    it "not fail on non-existent reference" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]\n[[John]]"
      pointer.drop_item "Bigfoot"
      pointer.content.should == "[[Jane]]\n[[John]]"
    end

    it "remove the last link" do
      pointer = Card.new :name=>"tp", :type=>"pointer", :content=>"[[Jane]]"
      pointer.drop_item "Jane"
      pointer.content.should == ""
    end
  end
   
  describe "html" do
    before do
      Card::Auth.as_bot do
        @card_name = "nonexistingcardmustnotexistthisistherule"
        @pointer = Card.create :name=>"tp", :type=>"pointer", :content=>"[[#{@card_name}]]"
        # similar tests for an inherited type of Pointer
        @my_list = Card.create! :name=>'MyList', :type_id=>Card::CardtypeID
        Card.create :name=>'MyList+*type+*default', :type_id=>Card::PointerID
        @inherit_pointer = Card.create :name=>'ip', :type_id=>@my_list.id, :content=>"[[#{@card_name}]]"
      end
    end
    it "should include nonexistingcardmustnotexistthisistherule in radio options" do
      option_html ="<input checked=\"checked\" class=\"pointer-radio-button\" id=\"pointer-radio-nonexistingcardmustnotexistthisistherule\" name=\"pointer_radio_button-tp\" type=\"radio\" value=\"nonexistingcardmustnotexistthisistherule\" />"
      @pointer.format.render_radio.should include(option_html)
      option_html ="<input checked=\"checked\" class=\"pointer-radio-button\" id=\"pointer-radio-nonexistingcardmustnotexistthisistherule\" name=\"pointer_radio_button-ip\" type=\"radio\" value=\"nonexistingcardmustnotexistthisistherule\" />"
      @inherit_pointer.format.render_radio.should include(option_html)
    end
    it "should include nonexistingcardmustnotexistthisistherule in checkbox options" do
      option_html = "<input checked=\"checked\" class=\"pointer-checkbox-button\" id=\"pointer-checkbox-nonexistingcardmustnotexistthisistherule\" name=\"pointer_checkbox\" type=\"checkbox\" value=\"nonexistingcardmustnotexistthisistherule\" />"
      @pointer.format.render_checkbox.should include(option_html)
      @inherit_pointer.format.render_checkbox.should include(option_html)
    end
    it "should include nonexistingcardmustnotexistthisistherule in select options" do
      option_html = %{<option value="#{@card_name}" selected="selected">#{@card_name}</option>}
      @pointer.format.render_select.should include(option_html)
      @inherit_pointer.format.render_select.should include(option_html)
    end
    it "should include nonexistingcardmustnotexistthisistherule in multiselect options" do
      option_html = %{<option value="#{@card_name}" selected="selected">#{@card_name}</option>}
      @pointer.format.render_multiselect.should include(option_html)
      @inherit_pointer.format.render_multiselect.should include(option_html)
    end
  end
  describe "css" do
    before do
      @css = '#box { display: block }'
      Card.create :name=>'my css', :content=> @css
    end
    it "should render CSS of items" do
      css_list = render_card :content, 
        { :type=>Card::PointerID, :name=>'my style list', :content=>'[[my css]]' }, 
        :format=>:css
#      css_list.should =~ /STYLE GROUP\: \"my style list\"/
#      css_list.should =~ /Style Card\: \"my css\"/
      css_list.should =~ /#{ Regexp.escape @css }/
    end
  end
  
  describe '#standardize_item' do
    it "should handle unlinked items" do
      pointer1 = Card.create! :name=>'pointer1', :type=>'Pointer', :content=>'bracketme'
      pointer1.content.should == '[[bracketme]]'
    end
  end
end
