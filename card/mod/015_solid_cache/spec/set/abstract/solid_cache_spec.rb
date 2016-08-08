describe Card::Set::Abstract::SolidCache do
  before do
    @card = Card['A']
    @card.singleton_class.send :include, Card::Set::Abstract::SolidCache
  end

  it 'generates solid cache' do
    @card.format_with_set(Card::Set::Abstract::SolidCache) do |format|
      format.render_core
    end
    Card::Auth.as_bot do
      expect(Card["A", :solid_cache]).to be_instance_of(Card)
      expect(Card["A", :solid_cache].content).to eq(@card.content)
    end
  end
end