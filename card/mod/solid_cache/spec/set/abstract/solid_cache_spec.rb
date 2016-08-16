
describe Card::Set::Abstract::SolidCache do
  context "render core view of a card" do
    before do
      @card = Card["A"]
    end

    let(:core_view) { 'Alpha <a class="known-card" href="/Z">Z</a>' }
    context "with solid cache" do
      it "saves core view in solid cache card" do
        @card.format_with_set(Card::Set::Abstract::SolidCache, &:render_core)
        Card::Auth.as_bot do
          expect(Card["A", :solid_cache]).to be_instance_of(Card)
          expect(Card["A", :solid_cache].content).to eq(core_view)
        end
      end

      it "uses solid cache card content as core view" do
        @card.format_with_set(Card::Set::Abstract::SolidCache) do |format|
          Card::Auth.as_bot do
            Card["A"].solid_cache_card.update_attributes! content: "cache"
          end
          expect(format._render_core).to eq "cache"
        end
      end
    end
    context "with solid cache disabled" do
      it "ignores solid cache card content" do
        @card.format_with_set(Card::Set::Abstract::SolidCache) do |format|
          Card::Auth.as_bot do
            Card["A"].solid_cache_card.update_attributes! content: "cache"
          end
          expect(format._render_core(solid_cache: false)).to eq core_view
        end
      end
    end
  end

  # rubocop:disable ClassAndModuleChildren
  # rubocop:disable Documentation
  context "when cached content expired" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "volatile", codename: "volatile",
                     content: "chopping"
        Card.create! name: "cached", codename: "cached",
                     content: "chopping and {{volatile|core}}"
      end
      Card::Codename.reset_cache
    end
    describe ".cache_update_trigger" do
      before do
        module Card::Set::Self::Cached
          extend Card::Set
          include_set Card::Set::Abstract::SolidCache

          ensure_set { Card::Set::Self::Volatile }
          cache_update_trigger Card::Set::Self::Volatile do
            Card["cached"]
          end
        end
      end

      it "updates solid cache card" do
        Card::Auth.as_bot do
          Card["volatile"].update_attributes! content: "changing"
        end
        expect(Card["cached", :solid_cache].content)
          .to eq "chopping and changing"
      end
    end

    describe ".cache_expire_trigger" do
      before do
        module Card::Set::Self::Cached
          extend Card::Set
          include_set Card::Set::Abstract::SolidCache

          ensure_set { Card::Set::Self::Volatile }
          cache_expire_trigger Card::Set::Self::Volatile do
            Card["cached"]
          end
        end
      end

      it "expires solid cache card" do
        Card["cached"].format(:html)._render_core
        expect(Card["cached", :solid_cache]).to be_instance_of Card
        Card::Auth.as_bot do
          Card["volatile"].update_attributes! content: "changing"
        end
        expect(Card["cached", :solid_cache]).to be_falsey
      end
    end
  end
  # rubocop:enable ClassAndModuleChildren
  # rubocop:enable Documentation
end
