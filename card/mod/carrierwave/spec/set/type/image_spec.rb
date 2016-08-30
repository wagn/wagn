# -*- encoding : utf-8 -*-require 'image_spec'

describe Card::Set::Type::Image do
  it "has special editor" do
    assert_view_select render_editor("Image"), 'div[class="choose-file"]' do
      assert_select 'input[class~="file-upload slotter"]'
    end
  end

  it "handles size argument in nest syntax" do
    file = File.new File.join(FIXTURES_PATH, "mao2.jpg")
    image_card = Card.create! name: "TestImage", type: "Image", image: file
    including_card = Card.new name: "Image1",
                              content: "{{TestImage | core; size:small }}"
    rendered = including_card.format._render :core
    assert_view_select(
      rendered, "img[src=?]",
      "/files/~#{image_card.id}/#{image_card.last_content_action_id}-small.jpg"
    )
  end

  context "newly created image card" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "image card", type: "image",
                     image: File.new(File.join(FIXTURES_PATH, "mao2.jpg"))
      end
    end
    subject { Card["image card"] }
    it "stores correct identifier" do
      expect(subject.content)
        .to eq "~#{subject.id}/#{subject.last_action_id}.jpg"
    end

    it "stores image" do
      expect(subject.image.size).to eq 7202
    end

    it "stores small size" do
      expect(subject.image.small.size).to be < 6000
      expect(subject.image.small.size).to be > 0
    end

    it "stores icon size" do
      expect(subject.image.icon.size).to be < 3000
      expect(subject.image.icon.size).to be > 0
    end

    it "saves original file name as action comment" do
      expect(subject.last_action.comment).to eq "mao2.jpg"
    end

    it "has correct original filename" do
      expect(subject.original_filename).to eq "mao2.jpg"
    end

    it "has correct url" do
      expect(subject.image.url)
        .to eq "/files/~#{subject.id}/#{subject.last_action_id}-original.jpg"
    end

    describe "view: source" do
      it "renders url" do
        expect(subject.format.render(:source))
          .to eq("/files/~#{subject.id}/#{subject.last_action_id}-medium.jpg")
      end
    end

    describe "view: act_expanded" do
      it "gets image url" do
        render_args = { act: subject.last_act, action_view: :expanded }
        act_summary = subject.format.render :act, render_args
        current_url = subject.image.versions[:medium].url
        expect(act_summary).to match(/#{Regexp.quote current_url}/)
      end
    end

    context "updated file card" do
      before do
        subject.update_attributes!(
          image: File.new(File.join(FIXTURES_PATH, "rails.gif"))
        )
      end
      it "updates file" do
        expect(subject.image.size).to eq 8533
      end

      it "updates original file name" do
        expect(subject.image.original_filename).to eq "rails.gif"
      end

      it "updates url" do
        expect(subject.image.url)
          .to eq "/files/~#{subject.id}/#{subject.last_action_id}-original.gif"
      end
    end
  end

  describe "*logo mod image" do
    subject { Card[:logo] }
    it "exists" do
      expect(subject.image.size).to be > 0
    end
    it "has correct url" do
      expect(subject.image.url).to eq "/files/:logo/standard-original.png"
    end
    it "has correct url as content" do
      expect(subject.content).to eq ":#{subject.codename}/standard.png"
    end

    it "becomes a regular file when changed" do
      Card::Auth.as_bot do
        subject.update_attributes!(
          image: File.new(File.join(FIXTURES_PATH, "rails.gif"))
        )
      end
      expect(subject.coded?).to be_falsey
      expect(subject.image.url)
        .to eq "/files/~#{subject.id}/#{subject.last_action_id}-original.gif"
    end

    describe "#coded?" do
      it "returns true" do
        expect(subject.coded?).to be_truthy
      end
    end

    describe "source view" do
      it "renders url with medium version" do
        expect(subject.format.render_source)
          .to eq "/files/:#{subject.codename}/standard-medium.png"
      end
    end
  end

  describe "#delete_files_for_action" do
    subject do
      Card::Auth.as_bot do
        Card.create! name: "image card", type: "image",
                     image: File.new(File.join(FIXTURES_PATH, "mao2.jpg"))
      end
    end
    it "deletes all versions" do
      path = subject.image.path
      small_path = subject.image.small.path
      medium_path = subject.image.medium.path
      subject.delete_files_for_action(subject.last_action)
      expect(File.exist?(small_path)).to be_falsey
      expect(File.exist?(medium_path)).to be_falsey
      expect(File.exist?(path)).to be_falsey
    end
  end
end
