describe Card::Set::All::RichHtml::Toolbar do
  context "show toolbar" do
    subject do
      render_content "{{A|edit}}"
    end
    it "renders toolbar" do
      is_expected.to have_tag "div", with: { class: "SELF-a edit-view" } do
        with_tag "nav", with: { class: "toolbar" }
      end
    end
  end
  context "hidden toolbar" do
    subject do
      render_content "{{A|edit; hide: toolbar}}"
    end
    it "hides toolbar" do
      is_expected.to have_tag "div", with: { class: "SELF-a edit-view" } do
        without_tag "nav", with: { class: "toolbar" }
      end
    end
  end
end
