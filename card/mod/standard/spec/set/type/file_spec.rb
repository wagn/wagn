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

  context "updated file card" do
    subject do
      Card::Auth.as_bot do
        card = Card.create name: "file card", type_code: "file",
                           file: File.new(File.join(FIXTURES_PATH, "file1.txt"))
        file = File.new File.join(FIXTURES_PATH, "file2.txt")
        card.update_attributes! file: file
        card
      end
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

  it "creates empty file card without content" do
    card = Card.create name: "hide and seek", type_id: Card::FileID
    expect(card.content).to eq("")
  end

  it "handles urls as source" do
    # wagn.org is down so we need another url
    url = "http://wagn.org/files/bruce_logo-large-122798.png"
    # url = 'http://www.lcdmedia.de/UserFiles/Image/pages/reparatur/beamer_test.jpg'

    Card.create! name: "url test", type_id: Card::FileID, remote_file_url: url
    expect(Card["url test"].file.size).to be > 0
    expect(Card["url test"].file.url).to match(/\.png$/)
  end

  describe "storage type:" do
    let(:directory) { "philipp-test" }
    before { storage_config :cloud }
    after { Wagn.config.file_storage = :protected }
    subject do
      Card::Auth.as_bot do
        Card.create! name: "file card", type_code: "file",
                     file: File.new(File.join(FIXTURES_PATH, "file1.txt")),
                     storage_type: @storage_type || :cloud
      end
    end

    describe "cloud" do
      it "stores correct identifier ((<bucket>)/<card id>/<action id>.<ext>)" do
        expect(subject.content)
          .to eq "(test_bucket)/#{subject.id}/#{subject.last_action_id}.txt"
      end

      it "stores file" do
        expect(subject.file.read.strip).to eq "file1"
      end

      it "generates correct absolute url" do
        expect(subject.file.url)
          .to eq "http://#{directory}.s3.amazonaws.com/"\
               "files/#{subject.id}/#{subject.last_action_id}.txt"
      end
    end

    describe "unprotected" do
      it "creates public symlink" do
        @storage_type = :unprotected
        expect(subject.content)
          .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
        expect(public_path_exist?).to be_truthy
      end
    end

    describe "web" do
      subject do
        Card::Auth.as_bot do
          Card.create! name: "file card", type_code: "file",
                       file: "http://a.remote.file",
                       storage_type: :web
        end
      end
      it "saves external link as card content" do
        expect(subject.content).to eq "http://a.remote.file"
      end

      describe "view: source" do
        it "renders external link" do
          source_view = subject.format(:html)._render_source
          expect(source_view).to eq "http://a.remote.file"
        end
      end

      describe "view: core" do
        it "renders link to external link" do
          core_view = subject.format(:html)._render_core
          assert_view_select core_view, 'a[href="http://a.remote.file"]',
                             text: "Download file card"
        end
      end
    end

    describe "#update_storage_location" do
      context "when changed from cloud to protected" do
        it "copies file to local file system" do
          # not yet supported
          expect{subject.update_storage_location!(:protected)}
            .to raise_error(Card::Error)
          # expect(subject.content)
          #   .to eq "~#{subject.id}/#{subject.last_action_id - 1}.txt"
          # expect(File.read(subject.file.retrieve_path)).to eq "file1"
        end
      end

      context "when changed from protected to cloud" do
        it "copies file to cloud" do
          @storage_type = :protected
          expect(subject.content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
          subject.update_storage_location! :cloud

          expect(subject.content).to eq(
            "(test_bucket)/#{subject.id}/#{subject.last_action_id - 1}.txt"
          )
          url = subject.file.url
          expect(url).to match(/^http/)
          file_content = open(url).read
          expect(file_content.strip).to eq "file1"
        end
      end

      context "when changed from protected to unprotected" do
        before do
          @storage_type = :protected
        end
        it "creates public svmlink" do
          subject.update_storage_location! :unprotected
          expect(public_path_exist?).to be_truthy
        end
      end

      context "when changed from unprotected to protected" do
        before do
          @storage_type = :unprotected
        end
        it "removes public symlink" do
          expect(subject.content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"

          subject.update_storage_location! :protected
          expect(public_path_exist?).to be_falsey
        end
      end
    end

    def storage_config type=:unprotected
      Wagn.config.file_storage = type
      Wagn.config.file_buckets = {
        test_bucket: {
          provider: "fog/aws",
          credentials: bucket_credentials(:aws),
          subdirectory: "files",
          directory: directory,
          public: true,
          attributes: { "Cache-Control" => "max-age=#{365.day.to_i}" },
          authenticated_url_expiration: 180
        }
      }
    end

    def public_path_exist?
      File.exist? "public/files/~#{subject.id}/#{subject.last_action_id}.txt"
    end
  end
end
