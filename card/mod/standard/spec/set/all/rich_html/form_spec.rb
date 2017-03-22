# -*- encoding : utf-8 -*-

describe Card::Set::All::RichHtml::Form do
  describe "type_list" do
    before do
      @card = Card["UserForm"]  # no cards with this type
    end

    it "gets type options from type_field renderer method" do
      expect(@card.format.type_field).to match(/<option [^>]*selected/)
      tf = @card.format.type_field(no_current_type: true)
      expect(tf).not_to match(/<option [^>]*selected/)
      expect(tf.scan(/<option /).length).to eq(31)
      tf = @card.format.type_field
      expect(tf).to match(/<option [^>]*selected/)
      expect(tf.scan(/<option /).length).to eq(31)
    end

    it "gets type list" do
      Card::Auth.as :anonymous do
        tf = @card.format.type_field(no_current_type: true)
        expect(tf).not_to match(/<option [^>]*selected/)
        expect(tf.scan(/<option /).length).to eq(1)
        tf = @card.format.type_field
        expect(tf).to match(/<option [^>]*selected/)
        expect(tf.scan(/<option /).length).to eq(2)
      end
    end
  end

  context "type and header" do
    it "renders type without no-edit class when no cards of type" do
      card = Card["UserForm"]  # no cards with this type
      expect(card.format.render_type)
        .to match(/<a[^>]* class="([^"]*)?\bcardtype\b[^"]*"/)
      expect(card.format.render_type)
        .not_to match(/<a[^>]* class="([^"]*)?\bno-edit\b[^"]*"/)
    end
    it "renders type header with no-edit class when cards of type exist" do
      no_edit_card = Card["cardtype a"]
      expect(no_edit_card.format.render_type)
        .to match(/<a[^>]* class="([^"]*)?\bcardtype\b[^"]*"/)
      expect(no_edit_card.format.render_type)
        .to match(/<a[^>]* class="([^"]*)?\bno-edit\b[^"]*"/)
    end
  end
end
