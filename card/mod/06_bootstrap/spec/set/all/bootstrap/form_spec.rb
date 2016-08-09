describe Card::Set::All::Bootstrap::Form  do
  describe "input" do
    it "has form-group css class" do
      assert_view_select render_editor("Phrase"), 'input[type="text"][class~="form-control"]'
    end
  end

  describe "textarea" do
    it "has form-group css class" do
      assert_view_select render_editor("Plain Text"), 'textarea[class~="form-control"]'
    end
  end
end
