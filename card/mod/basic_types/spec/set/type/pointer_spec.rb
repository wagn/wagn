# -*- encoding : utf-8 -*-
describe Card::Set::Type::Pointer do
  describe "item_names" do
    it "should return array of names of items referred to by a pointer" do
      card = Card.new(type: "Pointer", content: "[[Busy]]\n[[Body]]")
      card.item_names.should == %w(Busy Body)
    end
  end

  describe "add_item" do
    it "add to empty ref list" do
      pointer = Card.new name: "tp", type: "pointer", content: ""
      pointer.add_item "John"
      pointer.content.should == "[[John]]"
    end

    it "add to existing ref list" do
      pointer = Card.new name: "tp", type: "pointer", content: "[[Jane]]"
      pointer.add_item "John"
      pointer.content.should == "[[Jane]]\n[[John]]"
    end

    it "not add duplicate entries" do
      pointer = Card.new name: "tp", type: "pointer", content: "[[Jane]]"
      pointer.add_item "Jane"
      pointer.content.should == "[[Jane]]"
    end
  end

  describe "drop_item" do
    it "remove the link" do
      content = "[[Jane]]\n[[John]]"
      pointer = Card.new name: "tp", type: "pointer", content: content
      pointer.drop_item "Jane"
      pointer.content.should == "[[John]]"
    end

    it "not fail on non-existent reference" do
      content = "[[Jane]]\n[[John]]"
      pointer = Card.new name: "tp", type: "pointer", content: content
      pointer.drop_item "Bigfoot"
      pointer.content.should == content
    end

    it "remove the last link" do
      pointer = Card.new name: "tp", type: "pointer", content: "[[Jane]]"
      pointer.drop_item "Jane"
      pointer.content.should == ""
    end
  end

  let(:pointer) do
    Card.create name: "tp", type: "pointer",
                content: "[[item1]]\n[[item2]]"
  end

  describe "#added_item_names" do
    it "recognizes added items" do
      Card::Auth.as_bot do
        pointer
        in_stage :validate,
                 on: :save,
                 trigger: -> do
                            pointer.update_attributes!(
                              content: "[[item1]]\n[[item2]]\n[[item3]]"
                            )
                          end do
          expect(added_item_names).to eq ["item3"]
        end
      end
    end

    it "ignores order" do
      Card::Auth.as_bot do
        pointer
        in_stage :validate,
                 on: :save,
                 trigger: -> do
                   pointer.update_attributes!(
                     content: "[[item2]]\n[[item1]]"
                   )
                 end do
          expect(added_item_names).to eq []
        end
      end
    end
  end

  describe "#dropped_item_names" do
    it "recognizes dropped items" do
      Card::Auth.as_bot do
        pointer
        in_stage :validate,
                 on: :save,
                 trigger: -> do
                   pointer.update_attributes!(
                     content: "[[item1]]"
                   )
                 end do
          expect(dropped_item_names).to eq ["item2"]
        end
      end
    end

    it "ignores order" do
      Card::Auth.as_bot do
        pointer
        in_stage :validate,
                 on: :save,
                 trigger: -> do
                   pointer.update_attributes!(
                     content: "[[item2]]\n[[item1]]"
                   )
                 end do
          expect(dropped_item_names).to eq []
        end
      end
    end
  end

  describe "#changed_item_names" do
    it "recognizes changed items" do
      Card::Auth.as_bot do
        pointer
        in_stage :validate,
                 on: :save,
                 trigger: -> do
                   pointer.update_attributes!(
                     content: "[[item1]]\n[[item3]]"
                   )
                 end do
          expect(changed_item_names.sort).to eq %w(item2 item3)
        end
      end
    end
  end

  describe "html" do
    before do
      Card::Auth.as_bot do
        @card_name = "nonexistingcardmustnotexistthisistherule"
        @pointer = Card.create name: "tp", type: "pointer",
                               content: "[[#{@card_name}]]"
        # similar tests for an inherited type of Pointer
        @my_list = Card.create! name: "MyList", type_id: Card::CardtypeID
        Card.create name: "MyList+*type+*default", type_id: Card::PointerID
        @inherit_pointer = Card.create name: "ip", type_id: @my_list.id,
                                       content: "[[#{@card_name}]]"
      end
    end

    it "should include nonexisting card in radio options" do
      common_html =
        'input[class="pointer-radio-button"]'\
        '[checked="checked"]'\
        '[type="radio"]'\
        '[value="nonexistingcardmustnotexistthisistherule"]'\
        '[id="pointer-radio-nonexistingcardmustnotexistthisistherule"]'
      option_html = common_html + '[name="pointer_radio_button-tp"]'
      assert_view_select @pointer.format.render_radio, option_html
      option_html = common_html + '[name="pointer_radio_button-ip"]'
      assert_view_select @inherit_pointer.format.render_radio, option_html
    end

    it "should include nonexisting card in checkbox options" do
      option_html =
        'input[class="pointer-checkbox-button"]'\
        '[checked="checked"]'\
        '[name="pointer_checkbox"][type="checkbox"]'\
        '[value="nonexistingcardmustnotexistthisistherule"]'\
        '[id="pointer-checkbox-nonexistingcardmustnotexistthisistherule"]'
      assert_view_select @pointer.format.render_checkbox, option_html
      assert_view_select @inherit_pointer.format.render_checkbox, option_html
    end

    it "should include nonexisting card in select options" do
      option_html = "option[value='#{@card_name}'][selected='selected']"
      assert_view_select @pointer.format.render_select, option_html, @card_name
      assert_view_select @inherit_pointer.format.render_select, option_html,
                         @card_name
    end

    it "should include nonexisting card in multiselect options" do
      option_html = "option[value='#{@card_name}'][selected='selected']"
      assert_view_select @pointer.format.render_multiselect, option_html,
                         @card_name
      assert_view_select @inherit_pointer.format.render_multiselect,
                         option_html, @card_name
    end
  end

  describe "css" do
    before do
      @css = "#box { display: block }"
      Card.create name: "my css", content: @css
    end
    it "should render CSS of items" do
      css_list = render_card(
        :content,
        { type: Card::PointerID, name: "my style list", content: "[[my css]]" },
        format: :css
      )
      #      css_list.should =~ /STYLE GROUP\: \"my style list\"/
      #      css_list.should =~ /Style Card\: \"my css\"/
      css_list.should =~ /#{Regexp.escape @css}/
    end
  end

  describe "#standardize_item" do
    it "should handle unlinked items" do
      pointer1 = Card.create!(
        name: "pointer1", type: "Pointer", content: "bracketme"
      )
      pointer1.content.should == "[[bracketme]]"
    end
  end
end
