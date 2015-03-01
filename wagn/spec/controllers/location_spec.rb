# -*- encoding : utf-8 -*-


#FIXME - this shouldn't really be with the controller specs

describe CardController, "location test from old integration" do
  routes { Decko::Engine.routes }

  before do
    login_as 'joe_user'
  end

  it "should test_previous_location_should_be_assigned_after_viewing" do
    get :read, :id=>"Joe_User"
    assert_equal "/Joe_User", assigns['previous_location']
  end

  it "should test_previous_location_should_not_be_updated_by_nonexistent_card" do
    get :read, :id=>"Joe_User"
    get :read, :id=>"Not_Me"
    get :read, :id=>'*previous'
    assert_redirected_to '/Joe_User'
  end

  it "should test_return_to_special_url_when_logging_in_after_visit" do
    # not sure this still tests the case, controller tests do not test routes
    get :read, :id=>'*recent'
    assert_equal "/*recent",  assigns['previous_location']
  end

  # FIXME: this should probably be files in the spot for a delete test
  it "should test_removal_and_return_to_previous_undeleted_card_after_deletion" do
    t1 = t2 = nil
    Card::Auth.as_bot do
      t1 = Card.create! :name => "Testable1", :content => "hello"
      t2 = Card.create! :name => "Testable1+bandana", :content => "world"
    end

    get :read, :id => t1.key
    get :read, :id => t2.key

    post :delete, :id=> '~'+t2.id.to_s
    assert_nil Card[ t2.name ]
    assert_redirected_to "/#{t1.name}"

    post :delete, :id => '~'+t1.id.to_s
    assert_redirected_to '/'
    assert_nil Card[ t1.name ]
  end

end
