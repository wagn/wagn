require File.dirname(__FILE__) + '/../test_helper'
class TagRevisionTest < Test::Unit::TestCase
  common_fixtures
  def setup
    setup_default_user
  end
 
  def test_invalid_on_create
    t0 = Tag.create! :name=>"1newtag"
    assert_raises ActiveRecord::RecordInvalid do t1 = Tag.create :name=>"" end
    assert_raises ActiveRecord::RecordInvalid do t1 = Tag.create :name=>"Til#{JOINT}da" end
    assert_raises ActiveRecord::RecordInvalid do t1 = Tag.create :name=>"Sl/sh"  end
    #assert_raises ActiveRecord::RecordInvalid do t1 = Tag.create :name=>"newtag" end ???
  end

  def test_invalid_on_rename
    t0 = Tag.create! :name=>"1newtag"
    t1 = Tag.create! :name=>"secondtag"
    assert_raises ActiveRecord::RecordInvalid do t1.rename ""       end
    assert_raises ActiveRecord::RecordInvalid do t1.rename "Til#{JOINT}da" end
    assert_raises ActiveRecord::RecordInvalid do t1.rename "Sl/sh"  end
    #assert_raises ActiveRecord::RecordInvalid do t1.rename "newtag" end ???
  end
 
 
  
end
