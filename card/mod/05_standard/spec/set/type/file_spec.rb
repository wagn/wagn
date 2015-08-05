# -*- encoding : utf-8 -*-

describe Card::Set::Type::File do
  context "new file card" do
    before do
      Card::Auth.as_bot do
        Card.create :name => "file card", :type_code=>'file', :file=>File.new( File.join FIXTURES_PATH, 'file1.txt' )
      end
    end
    subject { Card['file card'] }
    it "stores correct identifier (<card id>/<action id>.<ext>)" do
      expect(subject.content).to eq "~#{subject.id}/#{subject.last_action_id}.txt"
    end

    it "stores file" do
      expect(subject.file.read.strip).to eq "file1"
    end

    it "saves original file name as action comment" do
      expect(subject.last_action.comment).to eq "file1.txt"
    end

    it "has correct originalf filename" do
      expect(subject.original_filename).to eq "file1.txt"
    end

    it "has correct url" do
      expect(subject.file.url).to eq "/files/~#{subject.id}/#{subject.last_action_id}.txt"
    end

    describe '#mod_file?' do
      it 'returns false' do
        expect(subject.mod_file?).to be_falsey
      end
    end

    describe 'view: source' do
      it 'renders url' do
        expect(subject.format.render(:source)).to eq("/files/~#{subject.id}/#{subject.last_action_id}.txt")
      end
    end

    context "updated file card" do
      before do
        subject.update_attributes! :file=>File.new( File.join FIXTURES_PATH, 'file2.txt' )
      end
      it "updates file" do
        expect(subject.file.read.strip).to eq "file2"
      end

      it "updates original file name" do
        expect(subject.original_filename).to eq "file2.txt"
      end

      it "updates url" do
        expect(subject.file.url).to eq "/files/~#{subject.id}/#{subject.last_action_id}.txt"
      end
    end
  end

  context "mod file" do
    subject { Card[:logo] }
    describe "#mod_file?" do
      it "returns the mod name" do
        expect(subject.mod_file?).to eq('05_standard')
      end
    end

    it "has correct url " do
      expect(subject.content).to eq ":#{subject.codename}/05_standard.png"
    end
  end
end
