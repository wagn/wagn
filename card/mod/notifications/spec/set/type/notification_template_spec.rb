describe Card::Set::Type::NotificationTemplate do
  include ActionController::TestCase::Behavior
  before do
    @routes = Decko::Engine.routes
    @controller = CardController.new
    login_as "joe_user"
    create "A+*self+*on update",
           type_id: Card::PointerID,
           content: "[[success]]"
  end

  def notify
    Card::Auth.as_bot do
      xhr :post, :update, id: "~#{Card['A'].id}",
                          card: { "content" => "change" }
    end
  end

  context "notification template without fields" do
    before do
      create "success", type_id: Card::NotificationTemplateID,
                        content: "success"
    end

    describe "#deliver" do
      it "is called on update" do
        notify_card = Card["success"]
        expect(notify_card).to receive(:deliver).once
        Card["A"].update_attributes! content: "change"
      end
    end

    it "shows notification" do
      notify
      expect(response.body).to have_tag "div.alert.alert-success" do
        with_text(/success/)
      end
    end
  end

  context "notification template with fields" do
    before do
      create "success",
             type_id: Card::NotificationTemplateID,
             content: "success",
             subfields: { contextual_class: "danger",
                          disappear: "1",
                          message: "failed" }
    end

    it "shows notification" do
      notify
      expect(response.body).to have_tag "div.alert.alert-danger._disappear" do
        with_text(/failed/)
      end
    end
  end
end
