require 'abstract_unit'

class User < ActiveRecord::Base
  cattr_accessor :current_user
end

class Entry < ActiveRecord::Base
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by"
end

class Post < ActiveRecord::Base
  record_userstamps = false
end

class Customer < ActiveRecord::Base
  cattr_accessor :current_user
end

class UserstampTest < Test::Unit::TestCase
  fixtures :users, :entries, :posts

  def setup
    User.current_user = @first_user
  end

  def teardown
    User.current_user = nil
    Entry.user_model_name = :user
  end

  def test_ar_userstamp_loaded
    assert ActiveRecord::Base.include?(ActiveRecord::Userstamp)
    assert_equal @first_user, User.current_user
    assert_equal User, @first_entry.user_model
    assert_equal User, @second_entry.user_model
  end

  def test_column_write_method
    assert_equal @first_user, User.current_user
    assert Entry.new.respond_to?("created_by=")
    assert Entry.new.respond_to?("updated_by=")

    assert Post.new.respond_to?("created_by=")
    assert Post.new.respond_to?("updated_by=")
  end

  def test_column_read_method
    assert_equal @first_user, User.current_user
    assert Entry.new.respond_to?("created_by")
    assert Entry.new.respond_to?("updated_by")
    assert Post.new.respond_to?("created_by")
    assert Post.new.respond_to?("updated_by")
  end

  def test_created_by
    assert_equal @first_user, User.current_user
    assert_equal @first_user, @first_entry.created_by
    assert_equal @second_user, @second_entry.created_by

    assert_nil @first_post.created_by
    assert_nil @second_post.created_by
  end

  def test_updated_by
    assert_equal @first_user, User.current_user
    assert_equal @first_user, @first_entry.updated_by
    assert_equal @second_user, @second_entry.updated_by

    assert_nil @first_post.updated_by
    assert_nil @second_post.updated_by
  end

  def test_create_new
    assert_equal @first_user, User.current_user, 
    third_user = User.create("name" => "Tester Three")
    User.current_user = third_user
    assert_equal third_user, User.current_user

    third_entry = Entry.create("name" => "Third Entry")

    assert_equal User, third_entry.user_model
    assert_equal third_user, third_entry.created_by
    assert_equal third_user, third_entry.updated_by
  end

  def test_update_entry
    assert_equal @first_user, User.current_user
    @second_entry.update_attribute("name", "Updated by First User")

    User.current_user = @second_user
    assert_equal @second_user, User.current_user
    @first_entry.update_attribute("name", "Updated by Second User")

    assert_equal @first_user, @second_entry.updated_by
    assert_equal @second_user, @first_entry.updated_by
  end

  def test_create_and_update_entry
    assert_equal @first_user, User.current_user

    third_entry = Entry.create("name" => "Third Entry")
    User.current_user = @second_user
    assert_equal @second_user, User.current_user
    
    third_entry.update_attribute("name", "Updated by Second User")
    assert_equal @first_user, third_entry.created_by
    assert_equal @second_user, third_entry.updated_by
  end

  def test_update_with_nil_current_user
    assert_equal @first_user, User.current_user

    @first_entry.update_attribute("name", "Updated by Nil")

    assert_equal @first_user, @first_entry.created_by
    assert_equal @first_user, @first_entry.updated_by
  end

  def test_create_with_different_user_model
    assert_equal @first_user, User.current_user
    Customer.current_user = @first_customer
    assert_equal @first_customer, Customer.current_user
    
    Entry.user_model_name = :customer
    third_entry = Entry.create("name" => "Customer Created Entry")
    third_entry.save

    assert_equal third_entry.user_model, Customer
    assert_equal third_entry.created_by, @first_customer
    assert_equal third_entry.updated_by, @first_customer
  end

end
