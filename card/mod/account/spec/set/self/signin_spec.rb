# -*- encoding : utf-8 -*-

# FIXME: need more specific assertions

describe Card::Set::Self::Signin do
  before :each do
    @card = Card[:signin]
  end

  it "open view should have email and password fields" do
    open_view = @card.format.render_open
    expect(open_view).to match(/email/)
    expect(open_view).to match(/password/)
  end

  it "edit view should prompt for forgot password" do
    edit_view = @card.format.render_edit
    expect(edit_view).to match(/email/)
    expect(edit_view).to match(/reset_password/)
  end

  it "password reset success view should prompt to check email" do
    rps_view = @card.format.render_reset_password_success
    expect(rps_view).to match(/Check your email/)
  end

  it "delete action should sign out account" do
    expect(Card::Auth.current_id).to eq(Card["joe_user"].id)
    @card.delete
    expect(Card::Auth.current_id).to eq(Card::AnonymousID)
  end

  context "#update" do
    it "triggers signin with valid credentials" do
      @card.update_attributes! "+*email" => "joe@admin.com",
                               "+*password" => "joe_pass"
      expect(Card::Auth.current).to eq(Card["joe admin"])
    end

    it "does not trigger signin with bad email" do
      @card.update_attributes! "+*email" => "schmoe@admin.com",
                               "+*password" => "joe_pass"
      expect(@card.errors[:signin].first).to match(/Unrecognized email/)
    end

    it "does not trigger signin with bad password" do
      @card.update_attributes! "+*email" => "joe@admin.com",
                               "+*password" => "joe_fail"
      expect(@card.errors[:signin].first).to match(/Wrong password/)
    end
  end

  context "#reset password" do
    before :each do
      Card::Env.params[:reset_password] = true
    end

    it "should be triggered by an update" do
      # Card['joe admin'].account.token.should be_nil FIXME - this should be t
      @card.update_attributes! "+*email" => "joe@admin.com"
      expect(Card["joe admin"].account.token).not_to be_nil
    end

    it "should return an error if email is not found" do
      @card.update_attributes "+*email" => "schmoe@admin.com"
      expect(@card.errors[:email].first).to match(/not recognized/)
    end
  end
end
