# -*- encoding : utf-8 -*-

describe Card::Set::All::File do
  context "file" do
    before do
      rpdocu_an_error = asdf_asdf()
      Card::Auth.as_bot do
        Card.create :name => "maofile", :type_code=>'file', :attach=>File.new( File.join FIXTURES_PATH, 'mao2.jpg' )
      end
    end

    it "handles image with no read permission" do
      card = Card['maofile']
      expect(card.content).to eq "#{card.last_action_id}.jpg"
    end


  end

end
