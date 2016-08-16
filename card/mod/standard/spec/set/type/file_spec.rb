# -*- encoding : utf-8 -*-

describe Card::Set::Type::File do
  context "new file card" do
    before do
      Card::Auth.as_bot do
        Card.create name: "file card", type_code: "file",
                    file: File.new(File.join(FIXTURES_PATH, "file1.txt"))
      end
    end
    subject { Card["file card"] }
    it "stores correct identifier (<card id>/<action id>.<ext>)" do
      expect(subject.content)
        .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
    end

    it "stores file" do
      expect(subject.file.read.strip).to eq "file1"
    end

    it "saves original file name as action comment" do
      expect(subject.last_action.comment).to eq "file1.txt"
    end

    it "has correct original filename" do
      expect(subject.original_filename).to eq "file1.txt"
    end

    it "has correct url" do
      expect(subject.file.url).to(
        eq "/files/~#{subject.id}/#{subject.last_action_id}.txt"
      )
    end

    describe "#mod_file?" do
      it "returns false" do
        expect(subject.mod_file?).to be_falsey
      end
    end

    describe "view: source" do
      it "renders url" do
        expect(subject.format.render(:source)).to(
          eq "/files/~#{subject.id}/#{subject.last_action_id}.txt"
        )
      end
    end

    context "updated file card" do
      before do
        file = File.new File.join(FIXTURES_PATH, "file2.txt")
        subject.update_attributes! file: file
      end
      it "updates file" do
        expect(subject.file.read.strip).to eq "file2"
      end

      it "updates original file name" do
        expect(subject.original_filename).to eq "file2.txt"
      end

      it "updates url" do
        expect(subject.file.url)
          .to eq "/files/~#{subject.id}/#{subject.last_action_id}.txt"
      end
    end

    context "subcards" do
      it "handles file subcards" do
        file = File.open(File.join(FIXTURES_PATH, "file1.txt"))
        Card.create! name: "new card with file",
                     subcards: {
                       "+my file" => {
                         content: "ignore content",
                         type_id: Card::FileID,
                         file: file
                       }
                     }
        expect(Card["new card with file+my file"].file.file.read.strip)
          .to eq "file1"
      end
    end
  end

  it "creates empty file card without content" do
    card = Card.create name: "hide and seek", type_id: Card::FileID
    expect(card.content).to eq("")
  end

  it "handles urls" do
    # wagn.org is down so we need another url
    url = "http://wagn.org/files/bruce_logo-large-122798.png"
    # url = 'http://www.lcdmedia.de/UserFiles/Image/pages/reparatur/beamer_test.jpg'

    Card.create! name: "url test", type_id: Card::FileID, remote_file_url: url
    expect(Card["url test"].file.size).to be > 0
    expect(Card["url test"].file.url).to match(/\.png$/)
  end
end
