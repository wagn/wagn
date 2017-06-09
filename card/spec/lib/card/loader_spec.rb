# -*- encoding : utf-8 -*-

describe Card::Mod::Loader do
  # let(:card_double) { double "Card" }
  # let(:pat_all_double) { proxy Card::Set::All }
  # let(:format_double) { proxy Card::Format }
  # let(:html_format_double) { proxy Card::Format::HtmlFormat }
  # it "autos-load Card class methods from lib/card and mods" do
  #   #xpect(Card).to receive(:load_mods)
  #   #
  #   allow(Card::Mod::Loader).to receive(:load_mods)
  #   #card = Card[:all]
  #   #expect(card_double).to receive(:load_formats)
  #   #expect(Card).to receive(:load_sets)
  #   #expect(Card).to receive(:tracks).with(:any_args) # so Card still loads without core in failure testing
  #   Card[:all]
  #   expect(Card::Mod::Loader).to have_received(:load_mods)
  #   #expect(Card.instance_method(:version)).to be
  #   # allow(Card).to receive(:version)
  #   # expect(Card.instance_method(:type_card)).to be
  #   # allow(Card).to receive(:file_path_sdfs)
  #   #expect(Card.instance_method(:file_path)).to be
  # end
  # it "defines Card methods from modules" do
  #   expect(Card.instance_method(:set_modules)).to be
  # end
  # it "defines Formatter methods from modules" do
  #   #expect(Card.instance_method(:render_core)).to be
  #   expect(Card.instance_method(:_render_raw)).to be
  #   expect(Card.instance_method(:render_core)).to be
  #   expect(Card.instance_method(:_render_raw)).to be
  # end
  # it "defines Formatter methods from modules" do
  #   expect(html_format_double.method(:render_core)).to be
  #   expect(html_format_double.method(:_render_raw)).to be
  #   expect(html_format_double.method(:render_core)).to be
  #   expect(html_format_double.method(:_render_raw)).to be
  # end

  it "loads self set" do
    create_card "set test load", codename: "set_test_load"
    Card::Cache.reset_all
    class ::Card::Set::Self
      module SetTestLoad
        extend Card::Set
        def hello
          "hello"
        end
      end
    end

    expect(Card["set_test_load"]).to respond_to :hello
  end

  it "loads self set for junction card" do
    create_card "set+test+load", codename: "set_test_load"
    Card::Cache.reset_all
    class ::Card::Set::Self
      module SetTestLoad
        extend Card::Set
        def hello
          "hello"
        end
      end
    end

    expect(Card["set+test+load"]).to respond_to :hello
  end

  it "loads type set" do
    create_card "set test load", codename: "set_test_load", type_id: Card::CardtypeID
    Card::Cache.reset_all
    class ::Card::Set::Type
      module SetTestLoad
        extend Card::Set
        def hello
          "hello"
        end
      end
    end
    expect(Card.new(name: "test load", type: "set test load")).to respond_to :hello
  end

  it "loads type set for a junction cardtyp" do
    create_card "set+test load", codename: "set_test_load", type_id: Card::CardtypeID
    Card::Cache.reset_all
    class ::Card::Set::Type
      module SetTestLoad
        extend Card::Set
        def hi
          "hello"
        end
      end
    end
    expect(Card.new(name: "test load", type: "set+test load")).to respond_to :hi
  end

end
