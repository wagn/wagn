# -*- encoding : utf-8 -*-
require File.expand_path('../test_helper', File.dirname(__FILE__))
class WagnRubyTest < ActiveSupport::TestCase
  def setup
    super
  end

  def test_hash_from_semicolon_attr_list
    assert_equal( {}, Hash.new_from_semicolon_attr_list("") )
    assert_equal( {}, Hash.new_from_semicolon_attr_list(nil) )
    assert_equal( {:a=>'b', :c=>'4'}, Hash.new_from_semicolon_attr_list("a:b;c:4"))
    assert_equal( {:d=>'b', :e=>'4'}, Hash.new_from_semicolon_attr_list("d:b;e:4; "))
  end

  def test_pull
    assert_equal false, {:a=>'2'}.pull(:b)

    h = {:a=>'2', :b=>''}
    assert_equal false, h.pull(:b)
    assert_equal( {:a=>'2'}, h)

    h = {:a=>3}
    assert_equal 3, h.pull(:a)
    assert_equal({},h)

  end
end

