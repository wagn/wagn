# -*- encoding : utf-8 -*-

# FIXME: - this shouldn't really be with the controller specs

describe CardController, "location test from old integration" do
  routes { Decko::Engine.routes }

  before do
    login_as "joe_user"
  end

  describe "previous location" do
    it "gets updated after viewing" do
      get :read, id: "Joe_User"
      assert_equal "/Joe_User", Card::Env.previous_location
    end

    it "doesn't link to nonexistent cards" do
      get :read, id: "Joe_User"
      get :read, id: "Not_Me"
      get :read, id: "*previous"
      assert_redirected_to "/Joe_User"
    end
  end
end
