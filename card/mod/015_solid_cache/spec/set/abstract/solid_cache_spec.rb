
describe Card::Set::Abstract::SolidCache do
  context 'render core view of a card' do
    before do
      @card = Card['A']
    end

    let(:core_view) { 'Alpha <a class=\"known-card\" href=\"/Z\">Z</a>' }
    context 'with solid cache' do
      it 'saves core view in solid cache card' do
        @card.format_with_set(Card::Set::Abstract::SolidCache) do |format|
          format.render_core
        end

        Card::Auth.as_bot do
          expect(Card["A", :solid_cache]).to be_instance_of(Card)
          expect(Card["A", :solid_cache].content).to eq(core_view)
        end
      end

      it 'uses solid cache card content as core view' do
        @card.format_with_set(Card::Set::Abstract::SolidCache) do |format|
          Card::Auth.as_bot do
            Card["A"].solid_cache_card.update_attributes! content: 'cache'
          end
          expect(format._render_core).to eq 'cache'
        end
      end
    end
    context 'with solid cache disabled' do
      it 'ignores solid cache card content' do
        @card.format_with_set(Card::Set::Abstract::SolidCache) do |format|
          Card::Auth.as_bot do
            Card["A"].solid_cache_card.update_attributes! content: 'cache'
          end
          expect(format._render_core(solid_cache: false)).to eq core_view
        end
      end
    end
  end

  context 'when cached content expired' do
    before  do
      class Card; module Set; module Type; module Basic; module WithCache
        extend Card::Set
        include_set Card::Set::Abstract::SolidCache

        cache_update_trigger Card::Set::Type::Basic do
          Card["B"]
        end
      end; end; end; end; end
    end

    describe '.cache_update_trigger' do
      it 'updates solid cache card' do
        Card::Auth.as_bot do
          Card['Z'].update_attributes! content: 'new content'
        end
        expect(Card['B', :solid_cache].content).to match(/Beta.*new content/m)
      end
    end

    describe '.cache_expire_trigger' do
      it 'expires solid cache card' do
        Card['B'].format(:html)._render_core
        expect(Card['B', :solid_cache]).to be_instance_of Card
        Card::Auth.as_bot do
          Card['Z'].update_attributes! content: 'new content'
        end
        expect(Card['B', :solid_cache]).to be_falsey
      end
    end
  end
end