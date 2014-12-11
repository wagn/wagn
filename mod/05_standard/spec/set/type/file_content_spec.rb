# -*- encoding : utf-8 -*-

describe Card::Set::Type::FileContent do
  before do
    Card::Auth.current_id = Card::WagnBotID
    @file_path_to_test = "WagnGem:mod/05_standard/set/type/file_content.rb"
  end
  context "when in HTML format" do
    it "should have a plain editor" do
      assert_view_select render_editor('FileContent'), render_editor('PlainText')
    end
    describe "core view" do
      it "should escape the content" do
        expect(render_card( :core, :type=>'FileContent', :content=>@file_path_to_test )).to eq(CGI.escapeHTML render_card( :raw, :type=>'FileContent', :content=>@file_path_to_test ))
      end
    end
  end
  context "when in other formats" do
    describe "core view" do
      it "should render the raw view" do
        expect(render_card( :core,{ :type=>'FileContent', :content=>@file_path_to_test},{:format=>:js} )).to eq(CGI.escapeHTML render_card( :raw, :type=>'FileContent', :content=>@file_path_to_test ))
      end
    end
    describe "raw view" do
      context "when content starts with 'WagnGem'"
        it "should read file in wagn gem folders" do
          expect(render_card( :raw, :type=>'FileContent', :content=>@file_path_to_test)).to eq(::File.read @file_path_to_test)
        end
      end
      it "should read file in decko's mod folder" do
        path = Dir.pwd+"/mod/test.txt"
        ::File.open(path, 'w') {|f| f.write("testing now") }
        expect(render_card( :raw, :type=>'FileContent', :content=>path)).to eq("testing now")
        ::File.delete path
      end
      context "when accessing files outside Wagn Gem or decko's mod folder" do
        it "should show 'Insecure path. Path should be within Wagn Gem or wagn mod.'" do
          expect(render_card( :raw, :type=>'FileContent', :content=>"/")).to eq('Insecure path. Path should be within Wagn Gem or wagn mod.')
        end
      end
      context "when file does not exist" do
        it "should show 'Non existing file path.'" do
          expect(render_card( :raw, :type=>'FileContent', :content=>"WagnGem:mod/05_standard/set/type/file_content.rb1")).to eq('Non existing file path.')
        end
      end
    end
  end
end
