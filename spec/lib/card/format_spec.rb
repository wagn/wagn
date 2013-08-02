# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Format do

  describe :render do
    it "should ignore underscores in view names" do
      render_card(:not_found).should == render_card('not found')
    end
    
    it "should render denial when user lacks read permissions" do
      c = Card.fetch('Administrator links')
      c.who_can(:read).should == [Card::AdminID]
      Account.as(:anonymous) do
        c.ok?(:read).should == false
        Card::Format.new(c).render(:core).should =~ /denied/
      end
    end
  end
#~~~~~~~~~~~~ special syntax ~~~~~~~~~~~#

  context "special syntax" do

    it "should allow for inclusion in links as in Cardtype" do
       Account.as_bot do
         Card.create! :name=>"TestType", :type=>'Cardtype', :content=>'[[/new/{{_self|linkname}}|add {{_self|name}} card]]'
         Card.create! :name=>'TestType+*self+*structure', :content=>'_self' #otherwise content overwritten by *structure rule
         Card::Format.new(Card['TestType']).render_core.should == '<a class="internal-link" href="/new/TestType">add TestType card</a>'
       end
    end

    it "css in inclusion syntax in wrapper" do
      c = Card.new :name => 'Afloatright', :content => "{{A|float:right}}"
      assert_view_select Card::Format.new(c)._render( :core ), 'div[style="float:right;"]'
    end

    it "HTML in inclusion syntax as escaped" do
      c =Card.new :name => 'Afloat', :type => 'Html', :content => '{{A|float:<object class="subject">}}'
      result = Card::Format.new(c)._render( :core )
      assert_view_select result, 'div[style="float:&amp;lt;object class=&amp;quot;subject&amp;quot;&amp;gt;;"]'
    end
  end
  
  context "language quirks" do
    it "should not fail on quirky language" do
      render_content( 'irc: man').should == 'irc: man'
      # this is really a specification issue, should we exclude the , like we do . at the end of a 'free' URI ?
      render_content( 'ethan@wagn.org, dude').should == '<a class="email-link" href="mailto:ethan@wagn.org">ethan@wagn.org</a>, dude'
    end
  
    it "should leave alone something that quacks like a URI when URI module raises invalid uri error" do
      # it does leave this alone, there was too much going on in one test
      wack_uri = 'git://<a href="/wagn/wagn.git">/wagn/wagn.git</a>'
      render_content( wack_uri ).should == wack_uri
    end
    it "should leave alone something that quacks like a URI when ?" do
      pending "its embeded in an <a> tag? quotes? need a spec"
      wack_uri = '<a href="http://github.com/wagn/wagn.git">github.com/wagn/wagn.git</a>'
      render_content( wack_uri ).should == wack_uri
    end
    it "should leave alone something that quacks like a URI when URI module raises invalid uri error" do
      render_content( 'mailto:eat@joe.com?v=k').should == "<a class=\"email-link\" href=\"mailto:eat@joe.com?v=k\">mailto:eat@joe.com?v=k</a>"
      #render_content( 'mailto:eat@joe.com?v=k').should == "mailto:eat@joe.com?v=k\">mailto:eat@joe.com?Subject=Hello"
    end
  end

#~~~~~~~~~~~~ Error handling ~~~~~~~~~~~~~~~~~~#

  describe "Error handling" do

    it "prevents infinite loops" do
      Card.create! :name => "n+a", :content=>"{{n+a|array}}"
      c = Card.new :name => 'naArray', :content => "{{n+a|array}}"
      Card::Format.new(c)._render( :core ).should =~ /too deep/
    end

    it "missing relative inclusion is relative" do
      c = Card.new :name => 'bad_include', :content => "{{+bad name missing}}"
      rr=(r=Card::Format.new(c))._render(:titled)
      rr.match(/Add.*\+.*bad name missing/).should_not be_nil
    end

    it "renders deny for unpermitted cards" do
      Account.as_bot do
        Card.create(:name=>'Joe no see me', :type=>'Html', :content=>'secret')
        Card.create(:name=>'Joe no see me+*self+*read', :type=>'Pointer', :content=>'[[Administrator]]')
      end
      assert_view_select Card::Format.new(Card.fetch('Joe no see me')).render(:core), 'span[class="denied"]'
    end
  end



  context "view" do

    it "content" do
      result = render_card(:content, :name=>'A+B')
      assert_view_select result, 'div[class="card-slot content-view ALL ALL_PLUS TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b"]' do
        assert_select 'span[class~="content-content content"]'
      end
    end


    describe "inclusions" do
      it "multi edit" do
        c = Card.new :name => 'ABook', :type => 'Book'
        rendered =  Card::Format.new(c).render( :edit )

        assert_view_select rendered, 'fieldset' do
          assert_select 'textarea[name=?][class="tinymce-textarea card-content"]', 'card[cards][~plus~illustrator][content]'
        end
      end
    end

    it "titled" do
      result = render_card :titled, :name=>'A+B'
      assert_view_select result, 'div[class~="titled-view"]' do
        assert_select 'h1' do
          assert_select 'span'
        end
        assert_select 'div[class~="titled-content"]', 'AlphaBeta'
      end
    end

    context "full wrapping" do
      before do
        @ocslot = Card::Format.new(Card['A'])
      end

      it "should have the appropriate attributes on open" do
        assert_view_select @ocslot.render(:open), 'div[class="card-slot open-view card-frame ALL TYPE-basic SELF-a"]' do
          assert_select 'div[class="card-header"]' do
            assert_select 'h1[class="card-title"]'
          end
          assert_select 'div[class~="card-body"]'
        end
      end

      it "should have the appropriate attributes on closed" do
        v = @ocslot.render(:closed)
        assert_view_select v, 'div[class="card-slot closed-view ALL TYPE-basic SELF-a"]' do
          assert_select 'div[class="card-header"]' do
            assert_select 'h1[class="card-title"]'
          end
          assert_select 'span[class~="closed-content content"]'
        end
      end
    end

    context "Cards with special views" do
      it "should render setting view for a right set" do
         r = Card::Format.new(Card['*read+*right']).render
         r.should_not match(/error/i)
         r.should_not match('No Card!')
         assert_view_select r, 'table[class="set-rules"]' do
           assert_select 'a[href~="/*read+*right+*input?view=open_rule"]', :text => 'input'
         end
      end

      it "should render setting view for a *input rule" do
        Account.as_bot do
          r = Card::Format.new(Card.fetch('*read+*right+*input',:new=>{})).render_open_rule
          r.should_not match(/error/i)
          r.should_not match('No Card!')
          #warn "r = #{r}"
          assert_view_select r, 'tr[class="card-slot open-rule edit-rule"]' do
            assert_select 'input[id="success_id"][name=?][type="hidden"][value="*read+*right+*input"]', 'success[id]'
          end
        end
      end
    end

    context "Simple page with Default Layout" do
      before do
        Account.as_bot do
          card = Card['A+B']
          @simple_page = Card::HtmlFormat.new(card).render(:layout)
          #warn "render sp: #{card.inspect} :: #{@simple_page}"
        end
      end


      it "renders top menu" do
        #warn "sp #{@simple_page}"
        assert_view_select @simple_page, 'div[id="menu"]' do
          assert_select 'a[class="internal-link"][href="/"]', 'Home'
          assert_select 'a[class="internal-link"][href="/recent"]', 'Recent'
          assert_select 'form.navbox-form[action="/:search"]' do
            assert_select 'input[name="_keyword"]'
          end
        end
      end

      it "renders card header" do
        # lots of duplication here...
        assert_view_select @simple_page, 'div[class="card-header"]' do
          assert_select 'h1[class="card-title"]'
        end
      end

      it "renders card content" do
        #warn "simple page = #{@simple_page}"
        assert_view_select @simple_page, 'div[class="open-content content card-body"]', 'AlphaBeta'
      end
 
      it "renders card credit" do
        assert_view_select @simple_page, 'div[id="credit"]', /Wheeled by/ do
          assert_select 'a', 'Wagn'
        end
      end
    end

    context "layout" do
      before do
        Account.as_bot do
          @layout_card = Card.create(:name=>'tmp layout', :type=>'Layout')
          #warn "layout #{@layout_card.inspect}"
        end
        c = Card['*all+*layout'] and c.content = '[[tmp layout]]'
        @main_card = Card.fetch('Joe User')
        #warn "lay #{@layout_card.inspect}, #{@main_card.inspect}"
      end

      it "should default to core view when in layout mode" do
        @layout_card.content = "Hi {{A}}"
        Account.as_bot { @layout_card.save }

        Card::Format.new(@main_card).render(:layout).should match('Hi Alpha')
      end

      it "should default to open view for main card" do
        @layout_card.content='Open up {{_main}}'
        Account.as_bot { @layout_card.save }

        result = Card::Format.new(@main_card).render_layout
        result.should match(/Open up/)
        result.should match(/card-header/)
        result.should match(/Joe User/)
      end

      it "should render custom view of main" do
        @layout_card.content='Hey {{_main|name}}'
        Account.as_bot { @layout_card.save }

        result = Card::Format.new(@main_card).render_layout
        result.should match(/Hey.*div.*Joe User/)
        result.should_not match(/card-header/)
      end

      it "shouldn't recurse" do
        @layout_card.content="Mainly {{_main|core}}"
        Account.as_bot { @layout_card.save }

        Card::Format.new(@layout_card).render(:layout).should == %{Mainly <div id="main">Mainly {{_main|core}}</div>}
      end
    end


  end

  describe "cgi params" do
    it "renders params in card inclusions" do
      c = Card.new :name => 'cardcore', :content => "{{_card+B|core}}"
      result = Card::Format.new(c, :params=>{'_card' => "A"})._render_core
      result.should == "AlphaBeta"
    end

    it "should not change name if variable isn't present" do
      c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
      Card::Format.new(c)._render( :core ).should == "_card+B"
    end

  end

#~~~~~~~~~~~~~  content views
# includes some *right stuff


  context "Content rule" do
    it "closed_content is rendered as title + raw" do
      template = Card.new(:name=>'A+*right+*structure', :content=>'[[link]] {{inclusion}}')
      Card::Format.new(template)._render(:closed_content).should ==
        '<a href="/Basic" class="cardtype default-type">Basic</a> : [[link]] {{inclusion}}'
    end

    it "is used in new card forms when soft" do
      Account.as :joe_admin do
        content_card = Card["Cardtype E+*type+*default"]
        content_card.content= "{{+Yoruba}}"
        content_card.save!

        help_card    = Card.create!(:name=>"Cardtype E+*type+*add help", :content=>"Help me dude" )
        card = Card.new(:type=>'Cardtype E')

        assert_view_select Card::HtmlFormat.new(card).render_new, 'div[class~="content-editor"]' do
          assert_select 'textarea[class="tinymce-textarea card-content"]', :text => '{{+Yoruba}}'
        end
      end
    end

    it "is used in new card forms when hard" do
      Account.as :joe_admin do
        content_card = Card.create!(:name=>"Cardtype E+*type+*structure",  :content=>"{{+Yoruba}}" )
        help_card    = Card.create!(:name=>"Cardtype E+*type+*add help", :content=>"Help me dude" )
        card = Card.new(:type=>'Cardtype E')

        mock(card).rule_card(:thanks, {:skip_modules=>true}).returns(nil)
        mock(card).rule_card(:autoname).returns(nil)
        mock(card).rule_card(:default,  {:skip_modules=>true}   ).returns(Card['*all+*default'])
        mock(card).rule_card(:add_help, {:fallback=>:help} ).returns(help_card)
        rendered = Card::HtmlFormat.new(card).render_new
        #warn "rendered = #{rendered}"
        assert_view_select rendered, 'fieldset' do
          assert_select 'textarea[name=?][class="tinymce-textarea card-content"]', "card[cards][~plus~Yoruba][content]"
        end
      end
    end

    it "should be used in edit forms" do
      Account.as_bot do
        config_card = Card.create!(:name=>"templated+*self+*structure", :content=>"{{+alpha}}" )
      end
      @card = Card.fetch('templated')# :name=>"templated", :content => "Bar" )
      @card.content = 'Bar'
      result = Card::Format.new(@card).render :edit
      #warn "res #{@card.inspect}\n#{result}"
      assert_view_select result, 'fieldset' do
        assert_select 'textarea[name=?][class="tinymce-textarea card-content"]', 'card[cards][templated~plus~alpha][content]'
      end
    end

    it "work on type-plus-right sets edit calls" do
      Account.as_bot do
        Card.create(:name=>'Book+author+*type plus right+*default', :type=>'Phrase', :content=>'Zamma Flamma')
      end
      c = Card.new :name=>'Yo Buddddy', :type=>'Book'
      result = Card::HtmlFormat.new(c).render( :edit )
      assert_view_select result, 'fieldset' do
        assert_select 'input[name=?][type="text"][value="Zamma Flamma"]', 'card[cards][~plus~author][content]'
        assert_select %{input[name=?][type="hidden"][value="#{Card::PhraseID}"]},     'card[cards][~plus~author][type_id]'
      end
    end
  end


#~~~~~~~~~ special views


end
