# -*- encoding : utf-8 -*-

describe Card::Set::Type::File do
  def test_file no=1
    File.new(File.join(FIXTURES_PATH, "file#{no}.txt"))
  end
  def create_file_card storage_type, file=test_file, opts={}
    Card::Auth.as_bot do
      Card.create! opts.reverse_merge(name: "file card", type_id: Card::FileID,
                                      file: file, storage_type: storage_type,
                                      codename: "file_card_codename")
    end
  end

  let(:web_url) { "http://web.de/web_file.txt"}
  let(:mod_path) do
    deck_mod_path = Cardio.paths["mod"].existent.last
    File.join deck_mod_path, "test_mod"
  end

  let(:protected_file) { create_file_card :protected }
  let(:unprotected_file) { create_file_card :unprotected, test_file(2) }
  let(:coded_file) { Card[:logo] }
  let(:web_file) do
    Card::Auth.as_bot do
      Card.create! name: "file card", type_id: Card::FileID,
                   content: web_url, storage_type: :web
    end
  end
  let(:cloud_file) do
    storage_config :cloud
    create_file_card :cloud, bucket: :test_bucket
  end

  describe "view: core" do
    it "renders source view as link" do
      core_view = web_file.format(:html)._render_core
      assert_view_select core_view, "a[href=\"#{web_url}\"]",
                         text: "Download file card"
    end
  end

  describe "view: source" do
    def source_view card
      card.format.render(:source)
    end
    context "storage type: protected" do
      subject { source_view protected_file }
      it "renders protected url to be processed by wagn" do
        is_expected.to(
          eq "/files/~#{protected_file.id}/#{protected_file.last_action_id}.txt"
        )
      end
    end

    context "storage type: unprotected" do
      subject { source_view unprotected_file }
      it "renders relative url" do
        is_expected.to(
          eq "#{unprotected_file.id}/#{unprotected_file.last_action_id}.txt"
        )
      end
    end

    context "storage type: web" do
      subject { source_view web_file }
      it "renders saved url" do
        is_expected.to eq web_url
      end
    end

    context "storage type: coded" do
      subject { source_view coded_file }
      it "renders protected url to be processed by wagn" do
        is_expected.to(
          eq "/files/:#{coded_file.codename}/standard-medium.png"
        )
      end
    end

    context "storage type: cloud" do
      subject { source_view cloud_file }
      it "renders absolute url to cloud" do
        is_expected
          .to eq "http://#{directory}.s3.amazonaws.com/"\
                 "files/#{cloud_file.id}/#{cloud_file.last_action_id}.txt"
      end
    end
  end


  context "creating" do
    it "fails if no file given" do
      expect do
        Card::Auth.as_bot do
          Card.create! name: "hide and seek", type_id: Card::FileID
        end
      end.to raise_error ActiveRecord::RecordInvalid,
                         "Validation failed: File is missing"
    end

    it "allows no file if 'empty_ok' is true" do
      Card::Auth.as_bot do
        card = Card.create! name: "hide and seek", type_id: Card::FileID,
                            empty_ok: true
        expect(card).to be_instance_of(Card)
        expect(card.content).to eq ""
      end
    end

    it "handles urls as source" do
      url = "http://wagn.org/files/bruce_logo-large-122798.png"
      Card.create! name: "url test", type_id: Card::FileID, remote_file_url: url
      expect(Card["url test"].file.size).to be > 0
      expect(Card["url test"].file.url).to match(/\.png$/)
    end

    context "storage type:" do
      context "protected" do
        subject { protected_file }
        it "stores correct identifier (~<card id>/<action id>.<ext>)" do
          expect(subject.content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
        end

        it "stores file" do
          expect(File.exist?(subject.file.path)).to be_truthy
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

        it "doesn't create public symlink" do
          expect(subject.content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
          expect(public_path_exist?).to be_falsey
        end
      end

      context "unprotected" do
        subject { unprotected_file }
        it "stores correct identifier (~<card id>/<action id>.<ext>)" do
          expect(subject.content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
        end

        it "stores file" do
          expect(File.exist?(subject.file.path)).to be_truthy
          expect(subject.file.read.strip).to eq "file2"
        end

        it "saves original file name as action comment" do
          expect(subject.last_action.comment).to eq "file2.txt"
        end

        it "has correct original filename" do
          expect(subject.original_filename).to eq "file2.txt"
        end

        it "has correct url" do
          expect(subject.file.url).to(
            eq "#{subject.id}/#{subject.last_action_id}.txt"
          )
        end

        it "creates public symlink" do
          expect(subject.content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
          expect(public_path_exist?).to be_truthy
        end
      end

      context "web" do
        subject { web_file }
        it "saves url as identifier" do
          expect(subject.content).to eq web_url
        end

        it "has correct original filename" do
          expect(subject.original_filename).to eq "web_file.txt"
        end

        it "has correct url" do
          expect(subject.attachment.url).to eq web_url
        end

        it "accepts url as file argument" do
          Card::Auth.as_bot do
            card = Card.create! name: "file card", type_id: Card::FileID,
                                file: web_url, storage_type: :web
            expect(card.content).to eq web_url
          end
        end

        it "accepts url as remote url argument" do
          Card::Auth.as_bot do
            card = Card.create! name: "file card", type_id: Card::FileID,
                                remote_file_url: web_url, storage_type: :web
            expect(card.content).to eq web_url
          end
        end
      end

      describe "coded" do
        before do
          FileUtils.mkdir_p mod_path
          # file_dir = File.join(mod_path,  "file", "mod_file")
          # FileUtils.mkdir_p file_dir
          # File.open(File.join(file_dir, "test_mod.txt"),"w") do |f|
          #   f.puts "test"
          # end
        end
        after do
          FileUtils.rm_rf mod_path
        end
        let(:file_path) { File.join mod_path, "file", "mod_file", "file.txt" }

        subject do
          create_file_card :coded, test_file,
                           codename: "mod_file", mod: "test_mod"
        end
        it "stores correct identifier (:<codename>/<mod_name>.<ext>)" do
          expect(subject.content)
            .to eq ":#{subject.codename}/test_mod.txt"
        end

        it "has correct store path" do
          expect(subject.file.path).to eq file_path
        end

        it "has correct original filename" do
          expect(subject.original_filename).to eq "file1.txt"
        end

        it "stores file in mod directory" do
          subject
          expect(File.read(file_path).strip).to eq "file1"
        end

        it "has correct url" do
          expect(subject.file.url).to(
            eq "/files/:#{subject.codename}/test_mod.txt"
          )
        end
      end

      describe "cloud" do
        subject { cloud_file }
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

    end

    context "with subcards" do
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

  context "updating" do
    subject do
      card = protected_file
      card.update_attributes! file: test_file(2)
      card
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

    context "storage type: coded" do
      context "coded" do
        before do
          FileUtils.mkdir_p mod_path
        end

        subject do
          create_file_card :coded, test_file,
                           codename: "mod_file", mod: "test_mod"
        end
        it "changes storage type to default" do
          storage_config :protected
          subject.update_attributes! file: test_file(2)
          expect(subject.storage_type).to eq :protected
          expect(subject.content)
            .to eq "~#{subject.id}/#{subject.last_action_id}.txt"
        end
        it "keeps storage type :coded if explicitly set" do
          storage_config :protected
          subject.update_attributes! file: test_file(2), storage_type: :coded
          expect(subject.storage_type).to eq :coded
          expect(subject.content)
            .to eq ":#{subject.codename}/#{subject.last_action_id}.txt"
        end
      end
    end
  end

  context "deleting" do
    it "removes symlink for unprotected files" do

    end
  end

  describe "#update_storage_location" do
    before { storage_config :cloud }
    after { Wagn.config.file_storage = :protected }
    subject do
      Card::Auth.as_bot do
        Card.create! name: "file card", type_code: "file",
                     file: File.new(File.join(FIXTURES_PATH, "file1.txt")),
                     storage_type: @storage_type || :cloud
      end
    end
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

  def public_path_exist?
    File.exist? "public/files/#{subject.id}/#{subject.last_action_id}.txt"
  end

  let(:directory) { "philipp-test" }
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
end
