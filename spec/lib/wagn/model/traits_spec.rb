require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Card do
  before do
    User.as(:wagbot)
    # FIXME:pack needs to add type
    # Note I added this manually to the test db, and it works, but it fails
    # if we have to create the typecard here, that seems like a bug
    Card.create!( :name=>'Sol', :type=>'Cardtype' )
    Card.create!( :name=>"*sol+*right+*default", :type=>'Sol' )
    Card.create!( :name=>"B+*sol" ).typecode.should == "Sol"
  end
  
=begin
  describe "trait data setup" do
    it "should make Sol of +*type" do
    end
  end
=end

  describe "#menu_options" do
    it "verifies that menu_option work without extras" do
      c = Card.fetch('A')
      Wagn::Renderer::RichHtml.new(c).render_open.should be_html_with do
        span(:class=>'card-menu') {
          span(:class=>'card-menu-left') {
            li { a { text('View') } }
            li { a { text('Related') } }
          }
          li { a { text('Edit') } }
        }
      end
    end                                          

    it "verifies that the extension's menu_option is added after Edit" do
      c = Card.fetch('B')
      Wagn::Renderer::RichHtml.new(c).render_open.should be_html_with do
        span(:class=>'card-menu') {
          span(:class=>'card-menu-left') {
            li { a { text('View') } }
            li { a { text('Edit') } }
          }
          li { a { text('Declare') } }
        }
      end
    end                                          

    it "Error for missing setting card for form" do
      c = Card.fetch('B')
      (r=Wagn::Renderer::RichHtml.new(c).render(:declare)).should match(/Missing setting/)
    end

    it "Error for setting card wrong type for form" do
      Card.create!( :name=>"*sol+*right+*declare" )
      c = Card.fetch('B')
      (r=Wagn::Renderer::RichHtml.new(c).render(:declare)).should_not match(/Missing setting/)
      r.should match(/Setting not a Pointer/)
    end

    it "Error for no setting form pointee" do
      Card.create!( :name=>"*sol+*right+*declare", :type=>'Pointer' )
      c = Card.fetch('B')
      (r=Wagn::Renderer::RichHtml.new(c).render(:declare)).should_not match(/Missing setting/)
      r.should_not match(/Setting not a Pointer/)
      r.should match(/No form card/)
    end

    it "Renders a declaration form" do
      Card.create!( :name=>"*sol+*right+*declare", :type=>'Pointer', :content=>"[[*sol+declare]]\n[[*sol+special]]" )
      Card.create!( :name=>"*sol+declare", :content=>"{{+foo}}\n{{+bar}}\n{{Foobar+foo}}" )
      c = Card.fetch('B')
      (r=Wagn::Renderer::RichHtml.new(c).render(:declare)).should_not match(/Missing setting/)
      r.should_not match(/Setting not a Pointer/)
      r.should_not match(/No form card/)
      r.should be_html_with do
        form(:action=>"card/update/B+*sol") do
          input(:id=>"attribute", :name=>"attribute", :type=>"hidden", :value=>"declare") {}
          input(:name=>"ctxsig", :type=>"hidden") {}
          div(:class=>"field-in-multi") {
              input(:id=>"main_1_1_2-hidden-content", :name=>"cards[B~plus~*sol~plus~bar][content]", :type=>"hidden") {}
          }
        end
      end
    end
  end
  
end
