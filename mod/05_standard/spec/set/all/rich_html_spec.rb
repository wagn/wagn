# -*- encoding : utf-8 -*-

describe Card::Set::All::RichHtml do
  describe 'missing view' do
    it "should prompt to add" do
      expect(render_content('{{+cardipoo|open}}').match(/Add \<span/ )).not_to be_nil
    end
  end
  
  describe "type_list" do
    before do
      @card = Card['UserForm']  # no cards with this type
    end
    
    it "should get type options from type_field renderer method" do
      expect(@card.format.type_field).to match(/<option [^>]*selected/)
      tf=@card.format.type_field(:no_current_type=>true)
      expect(tf).not_to match(/<option [^>]*selected/)
      expect(tf.scan(/<option /).length).to eq(24)
      tf=@card.format.type_field
      expect(tf).to match(/<option [^>]*selected/)
      expect(tf.scan(/<option /).length).to eq(24)
    end
    
    it "should get type list" do
      Card::Auth.as :anonymous do
        tf=@card.format.type_field(:no_current_type=>true)
        expect(tf).not_to match(/<option [^>]*selected/)
        expect(tf.scan(/<option /).length).to eq(1)
        tf=@card.format.type_field
        expect(tf).to match(/<option [^>]*selected/)
        expect(tf.scan(/<option /).length).to eq(2)
      end
    end
  end
  
  context "type and header" do
    it "should render type without no-edit class when no cards of type" do
      card = Card['UserForm']  # no cards with this type
      expect(card.format.render_type).to match(/<a [^>]* class="([^"]* )?cardtype[^"]*"/)
      expect(card.format.render_type).not_to match(/<a [^>]* class="([^"]* )?no-edit[^"]*"/)
    end
    it "should render type header with no-edit class when cards of type exist" do
      no_edit_card = Card['cardtype a']
      expect(no_edit_card.format.render_type).to match(/<a [^>]* class="([^"]* )?cardtype[^"]*"/)
      expect(no_edit_card.format.render_type).to match(/<a [^>]* class="([^"]* )?no-edit[^"]*"/)
    end
  end
end
