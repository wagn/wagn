# encoding: utf-8
require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require File.expand_path('../../packs/pack_spec_helper', File.dirname(__FILE__))

#FIXME: None of these work now, since inclusion is handled at the slot/cache
# level, but these cases should still be covered by tests


describe Chunks::Include, "include chunk tests" do
  include ActionView::Helpers::TextHelper
  include MySpecHelpers

  before do
    Account.current_id= Card['joe_user'].id
  end


  it "should test_circular_inclusion_should_be_invalid" do
    oak = Card.create! :name=>'Oak', :content=>'{{Quentin}}'
    qnt = Card.create! :name=>'Quentin', :content=>'{{Admin}}'
    adm = Card['Quentin']
    adm.update_attributes :content => "{{Oak}}"
    Wagn::Renderer.new(adm).render_core.should match('too deep')
  end

  it "should test_missing_include" do
    @a = Card.create :name=>'boo', :content=>"hey {{+there}}"
    r=Wagn::Renderer.new(@a).render_core
    assert_view_select r, 'div[card-name="boo+there"][class~="missing-view"]'
  end

  it "should test_absolute_include" do
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha}}"
    assert_view_select Wagn::Renderer.new(beta).render_core, 'span[class~="content"]', "Pooey"
  end

  it "should test_template_inclusion" do
     age = newcard('age')
     template = Card['*template']
     specialtype = Card.create :typecode=>'Cardtype', :name=>'SpecialType'

     specialtype_template = specialtype.fetch(:trait=>:type,:new=>{}).fetch(:trait=>:content,:new=>{})
     specialtype_template.content = "{{#{SmartName.joint}age}}"
     Account.as_bot { specialtype_template.save! }
     assert_equal "{{#{SmartName.joint}age}}", Wagn::Renderer.new(specialtype_template).render_raw

     wooga = Card.create! :name=>'Wooga', :type=>'SpecialType'
     wooga_age = Card.create!( :name=>"#{wooga.name}#{SmartName.joint}age", :content=> "39" )
     Wagn::Renderer.new(wooga_age).render_core.should == "39"
     wooga_age.includers.map(&:name).should == ['Wooga']
   end

  it "should test_relative_include" do
    alpha = newcard 'Alpha', "{{#{SmartName.joint}Beta}}"
    beta = newcard 'Beta'
    alpha_beta = Card.create :name=>"#{alpha.name}#{SmartName.joint}Beta", :content=>"Woot"
    assert_view_select Wagn::Renderer.new(alpha).render_core, 'span[class~=content]', "Woot"
  end


  it "should test_shade_option" do
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha|shade:off}}"
    r=Wagn::Renderer.new(newcard('Bee', "{{Alpha|shade:off}}" )).render_core
    assert_view_select r, 'div[style~="shade:off;"]' do
      assert_select 'span[class~=content]', "Pooey"
    end
    r=Wagn::Renderer.new(newcard('Cee', "{{Alpha| shade: off }}" )).render_core
    assert_view_select r, 'div[style~="shade:off;"]' do
      assert_select 'span[class~=content]', "Pooey"
    end
    r=Wagn::Renderer.new(newcard('Dee', "{{Alpha| shade:off }}" )).render_core
    assert_view_select r, 'div[style~="shade:off;"]' do
      assert_select 'span[class~="content"]', "Pooey"
    end
    r=Wagn::Renderer.new(newcard('Eee', "{{Alpha| shade:on }}" )).render_core
    assert_view_select r, 'div[style~="shade:on;"]' do
      assert_select 'span[class~="content"]', "Pooey"
    end
  end


  # this tests container templating and inclusion syntax 'base:parent'
  it "should test_container_inclusion" do
    #pending "base:parent not supported now, can we make a similare test with _left ?"
    bob_city = Card.create! :name=>'bob+city', :content=> "Sparta"
    Account.as_bot { address_tmpl = Card.create! :name=>'address+*right+*content', :content =>"{{_left+city}}" }
    bob_address = Card.create! :name=>'bob+address'
    #FIXME -- does not work retroactively if template is created later.

    r=Wagn::Renderer.new(bob_address.reload).render_core
    assert_view_select r, 'span[class~=content]', "Sparta"
    Card.fetch("bob+address").includees.map(&:name).should == [bob_city.name]
  end


  it "should test_nested_include" do
    alpha = newcard 'Alpha', "{{Beta}}"
    beta = newcard 'Beta', "{{Delta}}"
    delta = newcard 'Delta', "Booya"
    r=Wagn::Renderer.new( alpha ).render_core
    #warn "r=#{r}"
    assert_view_select r, 'span[class~=content]', "Booya"
  end

end
