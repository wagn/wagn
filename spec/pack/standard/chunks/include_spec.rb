# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
require 'wagn/pack_spec_helper'



describe Card::Chunk::Include, "Inclusion" do
  include ActionView::Helpers::TextHelper
  include MySpecHelpers

  context "syntax" do
    before do
      @class= Card::Chunk::Include
    end
    
    it "should handle no pipes" do
      instance = @class.new( @class.full_match( '{{toy}}') , nil )
      instance.name.should == 'toy'
      instance.options[:inc_name].should == 'toy'
      instance.options.key?(:view).should == false
    end
    
    it "should handle single pipe" do
      options = @class.new( @class.full_match('{{toy|link}}'), nil ).options
      options[:inc_name].should == 'toy'
      options[:view].should == 'link'
      options.key?(:items).should == false
    end
    
    it "should handle multiple pipes" do
      options = @class.new( @class.full_match('{{box|open|closed}}'), nil ).options
      options[:inc_name].should == 'box'
      options[:view].should == 'open'
      options[:items][:view].should == 'closed'
      options[:items].key?(:items).should == false      
    end

    it "should handle multiple pipes with blank lists" do
      options = @class.new( @class.full_match('{{box||closed}}'), nil ).options
      options[:inc_name].should == 'box'
      options[:view].should == nil
      options[:items][:view].should == 'closed'
    end
    
    it "should treat :item as view of next level" do
      options = @class.new( @class.full_match('{{toy|link;item:name}}'), nil ).options
      options[:inc_name].should == 'toy'
      options[:view].should == 'link'
      options[:items][:view].should == 'name'
    end
  end

  context "rendering" do

    before do
      Account.current_id= Card['joe_user'].id
    end

    it "should handle absolute names" do
      alpha = newcard 'Alpha', "Pooey"
      beta = newcard 'Beta', "{{Alpha}}"
      result = Card::Format.new(beta).render_core
      #warn "result = #{result}"
      assert_view_select result, 'span[class~="content"]', "Pooey"
    end

    it "should handle simple relative names" do
      alpha = newcard 'Alpha', "{{#{Card::Name.joint}Beta}}"
      beta = newcard 'Beta'
      alpha_beta = Card.create :name=>"#{alpha.name}#{Card::Name.joint}Beta", :content=>"Woot"
      assert_view_select Card::Format.new(alpha).render_core, 'span[class~=content]', "Woot"
    end
    
    it "should handle complex relative names" do
      bob_city = Card.create! :name=>'bob+city', :content=> "Sparta"
      Account.as_bot { address_tmpl = Card.create! :name=>'address+*right+*structure', :content =>"{{_left+city}}" }
      bob_address = Card.create! :name=>'bob+address'

      r=Card::Format.new(bob_address.reload).render_core
      assert_view_select r, 'span[class~=content]', "Sparta"
      Card.fetch("bob+address").includees.map(&:name).should == [bob_city.name]
    end

    it "should handle nesting" do
      alpha = newcard 'Alpha', "{{Beta}}"
      beta = newcard 'Beta', "{{Delta}}"
      delta = newcard 'Delta', "Booya"
      r=Card::Format.new( alpha ).render_core
      #warn "r=#{r}"
      assert_view_select r, 'span[class~=content]', "Booya"
    end

    it "should handle options when nesting" do
      Card.create! :type=>'Pointer', :name=>'Livable', :content=>'[[Earth]]'
      Card.create! :name=>'Earth'
      
      render_content('{{Livable|core;item:link}}').should == render_content('{{Livable|core|link}}')
      render_content('{{Livable|core;item:name}}').should == render_content('{{Livable|core|name}}')
    end
    
    it "should prevent recursion" do
      oak = Card.create! :name=>'Oak', :content=>'{{Quentin}}'
      qnt = Card.create! :name=>'Quentin', :content=>'{{Admin}}'
      adm = Card['Quentin']
      adm.update_attributes :content => "{{Oak}}"
      result = Card::Format.new(adm).render_core
      result.should match('too deep')
    end

    it "should handle missing cards" do
      @a = Card.create :name=>'boo', :content=>"hey {{+there}}"
      r=Card::Format.new(@a).render_core
      assert_view_select r, 'div[card-name="boo+there"][class~="missing-view"]'
    end

    it "should handle structured cards" do
       age = newcard('age')
       template = Card['*template']
       specialtype = Card.create :typecode=>'Cardtype', :name=>'SpecialType'

       specialtype_template = specialtype.fetch(:trait=>:type,:new=>{}).fetch(:trait=>:structure,:new=>{})
       specialtype_template.content = "{{#{Card::Name.joint}age}}"
       Account.as_bot { specialtype_template.save! }
       assert_equal "{{#{Card::Name.joint}age}}", Card::Format.new(specialtype_template).render_raw

       wooga = Card.create! :name=>'Wooga', :type=>'SpecialType'
       wooga_age = Card.create!( :name=>"#{wooga.name}#{Card::Name.joint}age", :content=> "39" )
       Card::Format.new(wooga_age).render_core.should == "39"
       #warn "cards #{wooga.inspect}, #{wooga_age.inspect}"
       wooga_age.includers.map(&:name).should == ['Wooga']
     end



    it "should handle shading" do
      alpha = newcard 'Alpha', "Pooey"
      beta = newcard 'Beta', "{{Alpha|shade:off}}"
      r=Card::Format.new(newcard('Bee', "{{Alpha|shade:off}}" )).render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select 'span[class~=content]', "Pooey"
      end
      r=Card::Format.new(newcard('Cee', "{{Alpha| shade: off }}" )).render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select 'span[class~=content]', "Pooey"
      end
      r=Card::Format.new(newcard('Dee', "{{Alpha| shade:off }}" )).render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select 'span[class~="content"]', "Pooey"
      end
      r=Card::Format.new(newcard('Eee', "{{Alpha| shade:on }}" )).render_core
      assert_view_select r, 'div[style~="shade:on;"]' do
        assert_select 'span[class~="content"]', "Pooey"
      end
    end




  end

end
