require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../packs/pack_spec_helper')

#describe Card do
#  before do
#    Session.as_bot do
#      # FIXME:pack needs to add type
#      # Note I added this manually to the test db, and it works, but it fails
#      # if we have to create the typecard here, that seems like a bug
#      Card.create!( :name=>'Sol', :type=>'Cardtype' )
#      Card.create!( :name=>"*sol+*right+*default", :type=>'Sol' )
#      (c=Card.create!( :name=>"B+*sol" )).type_name.should == 'Sol'
#      c.typecode.should == nil
#    end
#  end
#
#=begin
#  describe "trait data setup" do
#    it "should make Sol of +*type" do
#    end
#  end
#=end
#
#  describe "#menu_options" do
#    it "verifies that menu_option work without extras" do
#      c = Card.fetch('A')
#      result=Wagn::Renderer::Html.new(c).render_open
#      assert_view_select(result, 'span[class="card-menu"]') do
#        assert_select('span[class="card-menu-left"]') do
#          assert_select('li',  "View" )
#          assert_select('li', "Related")
#        end
#        assert_select('li', "Edit")
#      end
#    end
#
#    it "verifies that the extension's menu_option is added after Edit" do
#      pending
#      c = Card.fetch('B')
#      #warn "renders #{Wagn::Renderer::Html.new(c).render}"
#      assert_view_select Wagn::Renderer::Html.new(c).render, 'span[class="card-menu"]' do
#        assert_select('span[class="card-menu-left"]') do
#          assert_select('li',  'View')
#          assert_select('li', 'Edit')
#        end
#        assert_select('li', 'Declare')
#      end
#    end
#
#    it "Error for missing setting card for form" do
#      pending
#      c = Card.fetch('B')
#      (r=Wagn::Renderer::Html.new(c).render(:declare)).should match(/Missing setting/)
#    end
#
#    it "Error for setting card wrong type for form" do
#      pending
#      Card.create!( :name=>"*sol+*right+*declare" )
#      c = Card.fetch('B')
#      (r=Wagn::Renderer::Html.new(c).render(:declare)).should_not match(/Missing setting/)
#      r.should match(/Setting not a Pointer/)
#    end
#
#    it "Error for no setting form pointee" do
#      pending
#      Card.create!( :name=>"*sol+*right+*declare", :type=>'Pointer' )
#      c = Card.fetch('B')
#      (r=Wagn::Renderer::Html.new(c).render(:declare)).should_not match(/Missing setting/)
#      r.should_not match(/Setting not a Pointer/)
#      r.should match(/No form card/)
#    end
#
#    it "Renders a declaration form" do
#      pending
#      Card.create!( :name=>"*sol+*right+*declare", :type=>'Pointer', :content=>"[[*sol+declare]]\n[[*sol+special]]" )
#      Card.create!( :name=>"*sol+declare", :content=>"{{+foo}}\n{{+bar}}\n{{Foobar+foo}}" )
#      c = Card.fetch('B')
#      (r=Wagn::Renderer::Html.new(c).render(:declare)).should_not match(/Missing setting/)
#      r.should_not match(/Setting not a Pointer/)
#      r.should_not match(/No form card/)
#      #warn "render is #{r}\n<<<<"
#      assert_view_select r, 'form[action="/card/update/B+*sol"]' do
#        assert_select('input[id="attribute"][name="attribute"][type="hidden"][value="declare"]')
#        assert_select('input[name="ctxsig"][type="hidden"]')
#        assert_select('div[class="field-in-multi"]') do
#            assert_select('input[id="main_1_1_2-hidden-content"][name="cards[B~plus~*sol~plus~bar][content]"][type="hidden"]')
#        end
#      end
#    end
#  end
#
#end
