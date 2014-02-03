# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Format do
=begin
  describe :render do
    it "should ignore underscores in view names" do
      render_card(:not_found).should == render_card('not found')
    end
    
    it "should render denial when user lacks read permissions" do
      c = Card.fetch('Administrator Menu')
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

    it "HTML in inclusion syntax stripped" do
      c =Card.new :name => 'Afloat', :type => 'Html', :content => '{{A|float:left<object class="subject">}}'
      result = Card::Format.new(c)._render( :core )
      assert_view_select result, 'div[style="float:left;"]'
    end
  end
  
  describe "language quirks" do
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


  describe "new_inclusion_card_args (with cgi params)" do
    
# WHERE WAS THIS USED?    
#    it "uses params for card name substitutions" do
#      c = Card.new :name => 'cardcore', :content => "{{_card+B|core}}"
#      result = Card::Format.new(c, :params=>{'_card' => "A"})._render_core
#      result.should == "AlphaBeta"
#    end

    it "should not change inclusion name if variable isn't present" do
      c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
      Card::Format.new(c)._render( :core ).should == "_card+B"
    end

  end

#~~~~~~~~~~~~~  content views
# includes some *right stuff


  context "structure rule" do
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
          assert_select 'textarea[name=?][class="tinymce-textarea card-content"]', "card[cards][+Yoruba][content]"
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
#      warn "res #{@card.inspect}\n#{result}"
      assert_view_select result, 'fieldset' do
        assert_select 'textarea[name=?][class="tinymce-textarea card-content"]', 'card[cards][+alpha][content]'
      end
    end

    it "works on type-plus-right sets edit calls" do
      Account.as_bot do
        Card.create(:name=>'Book+author+*type plus right+*default', :type=>'Phrase', :content=>'Zamma Flamma')
      end
      c = Card.new :name=>'Yo Buddddy', :type=>'Book'
      result = Card::HtmlFormat.new(c).render( :new )
      assert_view_select result, 'fieldset' do
        assert_select 'input[name=?][type="text"][value="Zamma Flamma"]', 'card[cards][+author][content]'
        assert_select %{input[name=?][type="hidden"][value="#{Card::PhraseID}"]},     'card[cards][+author][type_id]'
      end
    end
  end

=end
  describe '#show?' do
    before :all do
      @format = described_class.new Card.new
    end
    
    it "should respect defaults" do
      @format.show_view?( :menu, {}, :show ).should be_true
      @format.show_view?( :menu, {}, :hide ).should be_false
      @format.show_view?( :menu, {}        ).should be_true
    end
    
    it "should respect developer default overrides" do
      @format.show_view?( :menu, { :optional_menu=>:show }, :hide ).should be_true
      @format.show_view?( :menu, { :optional_menu=>:hide }, :show ).should be_false
      @format.show_view?( :menu, { :optional_menu=>:hide }        ).should be_false
    end
    
    it "should handle args from inclusions" do
      @format.show_view?( :menu, { :show=>'menu'         }, :hide     ).should be_true
      @format.show_view?( :menu, { :hide=>'menu, paging' }, :show     ).should be_false
      @format.show_view?( :menu, :show=>'menu', :optional_menu=>:hide ).should be_true      
    end
    
    it "should handle hard developer overrides" do
      @format.show_view?( :menu, :optional_menu=>:always, :hide=>'menu' ).should be_true
      @format.show_view?( :menu, :optional_menu=>:never,  :show=>'menu' ).should be_false
    end
    
  end

end
