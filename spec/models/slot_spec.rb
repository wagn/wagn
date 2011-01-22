require File.dirname(__FILE__) + '/../spec_helper'

describe Slot, "" do
  before { User.as :joe_user }
  def simplify_html string
    string.gsub(/\s*<!--[^>]*>\s*/, '').gsub(/\s*<\s*(\/?\w+)[^>]*>\s*/, '<\1>')
  end
  
  def simple_render(content)
    @card ||= Card.new
    @card.content=content
    Slot.new(@card).render(:naked)
  end

  describe "processes content" do
    it "simple card links" do
      simple_render("[[A]]").should=="<a class=\"known-card\" href=\"/wagn/A\">A</a>"
    end

    it "invisible comment inclusions as blank" do
      simple_render("{{## now you see nothing}}").should==''
    end
    
    it "visible comment inclusions as html comments" do
      simple_render("{{# now you see me}}").should == '<!-- # now you see me -->'
      simple_render("{{# -->}}").should == '<!-- # --&gt; -->'
    end

    it "renders name with layout" do
      c = Card.new :name => 'nameA', :content => "{{A|name}}"
      Slot.new(c, 'main_1').render_layout.should be_html_with do
        html { body {
          p {"A"}
        }}
      end
      c = Card.new :name => 'openA', :content => "{{A|open}}"
      Slot.new(c, :context=>'main_1', :view=>'open').render_layout.should be_html_with do
        body() {
          div(:class=>"title-menu") {
            a(:href=>"/wagn/A", :class=>"page-icon", :title=>"Go to: A") { }
          }
          span(:class=>"open-content content editOnDoubleClick") {
            a(:class=>"known-card", :href=>"/wagn/Z") { }
          }
        }
      end
    end



    it "image tags of different sizes" do
      Card.create! :name => "TestImage", :type=>"Image", :content =>   %{<img src="http://wagn.org/image53_medium.jpg">}
      c = Card.new :name => 'Image1', :content => "{{TestImage | naked; size:small }}"
      Slot.new(c).render( :naked ).should == %{<img src="http://wagn.org/image53_small.jpg">}
    end

    describe "css classes" do
      it "are correct for open view" do
        c = Card.new :name => 'Aopen', :content => "{{A|open}}"
        Slot.new(c).render(:naked).should be_html_with do
          div( :class => "card-slot paragraph ALL TYPE-basic SELF-a") {}
        end
      end
    end

    describe "css in inclusion syntax" do
      it "shows up" do
        c = Card.new :name => 'Afloatright', :content => "{{A|float:right}}"
        Slot.new(c).render( :naked ).should be_html_with do
          div(:style => 'float:right;') {}
        end
      end

      # I want this test to show the explicit escaped HTML, but be_html_with seems to escape it already :-/
      it "shows up with escaped HTML" do
        c =Card.new :name => 'Afloat', :type => 'Html', :content => '{{A|float:<object class="subject">}}'
        Slot.new(c).render( :naked ).should be_html_with do
          div(:style => 'float:<object class="subject">;') {}
        end
      end
    end


    describe "inclusions" do
      it "multi edit" do
        c = Card.new :name => 'ABook', :type => 'Book'
        Slot.new(c).render( :multi_edit ).should be_html_with do
          div :class => "field-in-multi" do
            input :name=>"cards[~plus~illustrator][content]", :type => 'hidden'
          end
        end
      end
    end

    describe "views" do
      it "open" do
        mu = mock(:mu)
        mu.should_receive(:generate).and_return("1")
        UUID.should_receive(:new).and_return(mu)
        c = Card.new :name => 'Aopen', :content => "{{A|open}}"
        Slot.new(c).render( :naked ).should be_html_with do
          div( :position => 1, :class => "card-slot") {
            div( :class => "card-header" )
            span( :class => "content")  {
              #p "Alpha"
            }
          }
        end
      end

      it "array (basic card)" do
        c = Card.new :name => 'ABarray', :content => "{{A+B|array}}"
        Slot.new(c).render( :naked ).should == %{["AlphaBeta"]}
      end

      it "naked" do
        c = Card.new :name => 'ABnaked', :content => "{{A+B|naked}}"
        Slot.new(c).render( :naked ).should == "AlphaBeta"
      end

      it "titled" do
        c = Card.new :name => 'ABtitled', :content => "{{A+B|titled}}"
        simplify_html(Slot.new(c).render( :naked )).should == "<h1><span>A</span><span>+</span><span>B</span></h1><div><span>AlphaBeta</span></div>"
      end
      it "name" do 
        c = Card.new :name => 'ABname', :content => "{{A+B|name}}"
        Slot.new(c).render( :naked ).should == %{A+B}
      end

      it "link" do
        c = Card.new :name => 'ABlink', :content => "{{A+B|link}}"
        Slot.new(c).render( :naked ).should == %{<a class="known-card" href="/wagn/A+B">A+B</a>}
      end

#Rails.logger.info "failing naked(search card) #{c_open}\nRenders:#{Slot.new(c_open).render_naked}\nRenders end"
      it "naked (search card)" do
       s = Card.create :type=>'Search', :name=>'Asearch', :content=>%{{"type":"User"}}
       cname = Card.new :name=>'AsearchNaked1',
                        :content=>"{{Asearch|naked;item:name}}"
       Slot.new(cname).render_naked.should match('search-result-item item-name')

       copen = Card.new :name => 'AsearchNaked1',
                        :content => "{{Asearch|naked;item:open}}"
       Slot.new(copen).render_naked.should match('search-result-item item-open')

       cclosed = Card.new :name => 'AsearchNaked',
                          :content => "{{Asearch|item:closed}}"
       Slot.new(cclosed).render_naked.should match('search-result-item item-closed')

       c = Card.new :name => 'AsearchNaked', :content => "{{Asearch|naked}}"
       Slot.new(c).render_naked.should match('search-result-item item-closed')
      end

      it "array (search card)" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Phrase", :content=>"say:\"what\""
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        c = Card.new :name => 'nplusarray', :content => "{{n+*plus cards+by create|array}}"
        Slot.new(c).render( :naked ).should == %{["10", "say:\\"what\\"", "30"]}
      end

      it "array (pointer card)" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Number", :content=>"20"
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        Card.create! :name => "npoint", :type=>"Pointer", :content => "[[n+a]]\n[[n+b]]\n[[n+c]]"
        c = Card.new :name => 'npointArray', :content => "{{npoint|array}}"
        Slot.new(c).render( :naked ).should == %q{["10", "20", "30"]}
      end

      it "array doesn't go in infinite loop" do
        Card.create! :name => "n+a", :content=>"{{n+a|array}}"
        c = Card.new :name => 'naArray', :content => "{{n+a|array}}"
        Slot.new(c).render( :naked ).should =~ /too deep/
      end
    end

    it "raw content" do
       @a = Card.new(:name=>'t', :content=>"{{A}}")
      Slot.new(@a).render(:raw).should == "{{A}}"
    end
  end

  describe "cgi params" do
    it "renders params in card inclusions" do
      c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
      result = Slot.new(c, :params=>{'_card' => "A"}).render_naked
      result.should == "AlphaBeta"
    end

    it "should not change name if variable isn't present" do
      c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
      Slot.new(c).render( :naked ).should == "_card+B"
    end
  end

  it "should use inclusion view overrides" do
    # FIXME love to have these in a scenario so they don't load every time.
    t = Card.create! :name=>'t1', :content=>"{{t2|card}}"
    Card.create! :name => "t2", :content => "{{t3|view}}"
    Card.create! :name => "t3", :content => "boo"

    # a little weird that we need :open_content  to get the version without
    # slot divs wrapped around it.
    s = Slot.new(t, :inclusion_view_overrides=>{ :open => :name } )
    s.render( :naked ).should == "t2"

    # similar to above, but use link
    s = Slot.new(t, :inclusion_view_overrides=>{ :open => :link } )
    s.render( :naked ).should == "<a class=\"known-card\" href=\"/wagn/t2\">t2</a>"

    s = Slot.new(t, :inclusion_view_overrides=>{ :open => :naked } )
    s.render( :naked ).should == "boo"
  end

  context "builtin card" do
    it "should render layout partial with name of card" do
      pending
      template = mock("template")
      template.should_receive(:render).with(:partial=>"builtin/builtin").and_return("Boo")
      builtin_card = Card.new( :name => "*builtin", :builtin=>true )
      slot = Slot.new( builtin_card )
      slot.render_raw.should == "Boo"
      slot.render(:raw).should == "Boo"
      slot = Slot.new( Card["*head"], "main_1", "view"  )
      slot.render(:naked).should == ''
    end
  end

  context "with content settings" do
    it "uses content setting" do
      pending
      @card = Card.new( :name=>"templated", :content => "bar" )
      config_card = Card.new(:name=>"templated+*self+*content", :content=>"Yoruba" )
      @card.should_receive(:setting_card).with("content","default").and_return(config_card)
      Slot.new(@card).render_raw.should == "Yoruba"
      @card.should_receive(:setting_card).with("content","default").and_return(config_card)
      @card.should_receive(:setting_card).with("add help","edit help")
      Slot.new(@card).render_new.should be_html_with do
        html { div(:class=>"unknown-class-name") {}}
      end
    end

    it "uses render content setting" do
      @card = Card.new( :name=>"templated", :content => "bar" )
      Card.new(:name=>"templated+*self+*content", :content=>"Yoruba" )
      config_card = Card.new(:name=>"templated+*self+*add help", :content=>"Help me" )
      #@card.should_receive(:setting_card).with("content","default").and_return(config_card)
      #@card.should_receive(:setting_card).with("add help","edit help").and_return(config_card)
      Slot.new(@card).render_new.should be_html_with do
        div { "Yorba"}
      end
    end

    it "doesn't use content setting if default is present" do
      @card = Card.new( :name=>"templated", :content => "Bar" )
      config_card = Card.new(:name=>"templated+*self+*default", :content=>"Yoruba" )
      @card.should_receive(:setting_card).with("content", "default").and_return(config_card)
      Slot.new(@card).render(:raw).should == "Bar"
    end

    # FIXME: this test is important but I can't figure out how it should be
    # working.
    it "uses content setting in edit" do
Rails.logger.info "failing start"
      config_card = Card.create!(:name=>"templated+*self+*content", :content=>"{{+alpha}}" )
Rails.logger.info "failing new templated"
      @card = Card.new( :name=>"templated", :content => "Bar" )
      @card.should_receive(:setting_card).with("content", "default").and_return(config_card)
Rails.logger.info "failing new about to render #{@card}"
      result = Slot.new(@card).render(:edit)
Rails.logger.info "failing done"
      result.should be_html_with do
        div :class => "field-in-multi" do
          input :name=>"cards[~plus~alpha][content]", :type => 'hidden'
        end
      end
    end
  end

  describe "diff" do
    it "should not overwrite empty content with current" do
      User.as(:wagbot)
      c = Card.create! :name=>"ChChChanges", :content => ""
      c.update_attributes :content => "A"
      c.update_attributes :content => "B"
      r = Slot.new(c).render_diff( c.revisions[0].content, c.revisions[1].content )
      r.should == "<ins class=\"diffins\">A</ins>"
    end
  end
end

