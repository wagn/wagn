# -*- encoding : utf-8 -*-

describe Card::Chunk::Include, "Inclusion" do
  include ActionView::Helpers::TextHelper

  context "syntax parsing" do
    before do
      @class= Card::Chunk::Include
    end
    
    it "should ignore invisible comments" do
      expect(render_content("{{## now you see nothing}}")).to eq('')
    end

    it "should handle visible comments" do
      expect(render_content("{{# now you see me}}")).to eq('<!-- # now you see me -->')
      expect(render_content("{{# -->}}")).to eq('<!-- # --&gt; -->')
    end
    
    it "should handle empty inclusions" do
      instance = @class.new( @class.full_match( '{{ }}' ) , nil )
      expect(instance.name).to eq('')
      expect(instance.options[:inc_syntax]).to eq(' ')
      instance1 = @class.new( @class.full_match( '{{|}}' ) , nil )
      expect(instance1.name).to eq('')
      expect(instance1.options[:inc_syntax]).to eq('|')
      
    end
    
    it "should handle no pipes" do
      instance = @class.new( @class.full_match( '{{toy}}') , nil )
      expect(instance.name).to eq('toy')
      expect(instance.options[:inc_name]).to eq('toy')
      expect(instance.options.key?(:view)).to eq(false)
    end
    
    it "should strip the name" do
      expect(@class.new( @class.full_match( '{{ toy }}') , nil ).name).to eq('toy')
    end
    
    it 'should strip html tags' do
      expect(@class.new( @class.full_match( '{{ <span>toy</span> }}') , nil ).name).to eq('toy')
      instance = @class.new( @class.full_match( '{{ <span>toy|open</span> }}') , nil )
      expect(instance.name).to eq('toy')
      expect(instance.options[:view]).to eq('open')
    end
    
    it "should handle single pipe" do
      options = @class.new( @class.full_match('{{toy|view:link;hide:me}}'), nil ).options
      expect(options[:inc_name]).to eq('toy')
      expect(options[:view]).to eq('link')
      expect(options[:hide]).to eq('me')
      expect(options.key?(:items)).to eq(false)
    end
    
    it "should handle multiple pipes" do
      options = @class.new( @class.full_match('{{box|open|closed}}'), nil ).options
      expect(options[:inc_name]).to eq('box')
      expect(options[:view]).to eq('open')
      expect(options[:items][:view]).to eq('closed')
      expect(options[:items].key?(:items)).to eq(false)      
    end

    it "should handle multiple pipes with blank lists" do
      options = @class.new( @class.full_match('{{box||closed}}'), nil ).options
      expect(options[:inc_name]).to eq('box')
      expect(options[:view]).to eq(nil)
      expect(options[:items][:view]).to eq('closed')
    end
    
    it "should treat :item as view of next level" do
      options = @class.new( @class.full_match('{{toy|link;item:name}}'), nil ).options
      expect(options[:inc_name]).to eq('toy')
      expect(options[:view]).to eq('link')
      expect(options[:items][:view]).to eq('name')
    end
  end

  context "rendering" do

    it "should handle absolute names" do
      alpha = newcard 'Alpha', "Pooey"
      beta = newcard 'Beta', "{{Alpha}}"
      result = beta.format.render_core
      assert_view_select result, 'div[class~="card-content"]', "Pooey"
    end

    it "should handle simple relative names" do
      alpha = newcard 'Alpha', "{{#{Card::Name.joint}Beta}}"
      beta = newcard 'Beta'
      alpha_beta = Card.create :name=>"#{alpha.name}#{Card::Name.joint}Beta", :content=>"Woot"
      assert_view_select alpha.format.render_core, 'div[class~=card-content]', "Woot"
    end
    
    it "should handle complex relative names" do
      bob_city = Card.create! :name=>'bob+city', :content=> "Sparta"
      Card::Auth.as_bot { address_tmpl = Card.create! :name=>'address+*right+*structure', :content =>"{{_left+city}}" }
      bob_address = Card.create! :name=>'bob+address'

      r=bob_address.reload.format.render_core
      assert_view_select r, 'div[class~=card-content]', "Sparta"
      expect(Card.fetch("bob+address").includees.map(&:name)).to eq([bob_city.name])
    end

    it "should handle nesting" do
      alpha = newcard 'Alpha', "{{Beta}}"
      beta = newcard 'Beta', "{{Delta}}"
      delta = newcard 'Delta', "Booya"
      r= alpha .format.render_core
      #warn "r=#{r}"
      assert_view_select r, 'div[class~=card-content]'
      expect(r).to match(/Booya/)
    end

    it "should handle options when nesting" do
      Card.create! :type=>'Pointer', :name=>'Livable', :content=>'[[Earth]]'
      Card.create! :name=>'Earth'
      
      expect(render_content('{{Livable|core;item:link}}')).to eq(render_content('{{Livable|core|link}}'))
      expect(render_content('{{Livable|core;item:name}}')).to eq(render_content('{{Livable|core|name}}'))
    end
    
    it "should prevent recursion" do
      oak = Card.create! :name=>'Oak', :content=>'{{Quentin}}'
      qnt = Card.create! :name=>'Quentin', :content=>'{{Admin}}'
      adm = Card['Quentin']
      adm.update_attributes :content => "{{Oak}}"
      result = adm.format.render_core
      expect(result).to match('too deep')
    end

    it "should handle missing cards" do
      @a = Card.create :name=>'boo', :content=>"hey {{+there}}"
      r=@a.format.render_core
      assert_view_select r, 'div[data-card-name="boo+there"][class~="missing-view"]'
    end

    it "should handle structured cards" do
      age = newcard('age')
      template = Card['*template']
      specialtype = Card.create :type_code=>'Cardtype', :name=>'SpecialType'
    
      specialtype_template = specialtype.fetch(:trait=>:type,:new=>{}).fetch(:trait=>:structure,:new=>{})
      specialtype_template.content = "{{#{Card::Name.joint}age}}"
      Card::Auth.as_bot { specialtype_template.save! }
      assert_equal "{{#{Card::Name.joint}age}}", specialtype_template.format.render_raw
    
      wooga = Card.create! :name=>'Wooga', :type=>'SpecialType'
      wooga_age = Card.create!( :name=>"#{wooga.name}#{Card::Name.joint}age", :content=> "39" )
      expect(wooga_age.format.render_core).to eq("39")
      #warn "cards #{wooga.inspect}, #{wooga_age.inspect}"
      expect(wooga_age.includers.map(&:name)).to eq(['Wooga'])
    end

    it "should handle shading" do
      alpha = newcard 'Alpha', "Pooey"
      beta = newcard 'Beta', "{{Alpha|shade:off}}"
      r=newcard('Bee', "{{Alpha|shade:off}}").format.render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select 'div[class~=card-content]', "Pooey"
      end
      r=newcard('Cee', "{{Alpha| shade: off }}").format.render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select 'div[class~=card-content]', "Pooey"
      end
      r=newcard('Dee', "{{Alpha| shade:off }}").format.render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select 'div[class~="card-content"]', "Pooey"
      end
      r=newcard('Eee', "{{Alpha| shade:on }}").format.render_core
      assert_view_select r, 'div[style~="shade:on;"]' do
        assert_select 'div[class~="card-content"]', "Pooey"
      end
    end

    #FIXME - should move code and test to core_ext or some such
    it 'Hash.new_from_semicolon_attr_list should work' do
      expect(Hash.new_from_semicolon_attr_list("")).to eq({})
      expect(Hash.new_from_semicolon_attr_list(nil)).to eq({})
      expect(Hash.new_from_semicolon_attr_list("a:b;c:4"  )).to eq({:a=>'b', :c=>'4'})
      expect(Hash.new_from_semicolon_attr_list("d:b;e:4; ")).to eq({:d=>'b', :e=>'4'})
    end

  end

end
