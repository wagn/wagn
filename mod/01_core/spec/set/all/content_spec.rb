# -*- encoding : utf-8 -*-

describe Card::Set::All::Content do
  describe 'save_draft' do
    it 'should store a draft revision' do
      @card = Card.create! :name=>"mango", :content=>"foo"
      @card.save_draft("bar")
      assert_equal 1, @card.drafts.length
      @card.save_draft("booboo")
      assert_equal 1, @card.drafts.length
      assert_equal "booboo", @card.drafts[0].content
    end
  end
end
