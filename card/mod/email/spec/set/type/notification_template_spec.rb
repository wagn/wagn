describe Card::Set::Type::NotificationTemplate do
  include ActionController::TestCase::Behavior

  before do
    Card::Auth.as_bot do
      create "success", type_id: Card::NotificationTemplateID,
             content: "success"
      ensure_card "A+*self+*on update",
                  type_id: Card::PointerID,
                  content: "[[success]]"
    end
  end

  describe "#deliver" do
    it "is called on update" do
      notify = Card["success"]
      expect(notify).to receive(:deliver).once
      Card["A"].update_attributes! content: "change"
    end
  end

  context "notification triggered" do
    before do
      @routes = Decko::Engine.routes
      @controller = CardController.new
      login_as "joe_user"
    end

    it "shows notification" do
      xhr :post, :update, id: "~#{Card["A"].id}",
          card: { "content" => "change" }
      expect(response.body).to have_tag "div.alert" do
        with_text /success/
      end
    end
  end
end
