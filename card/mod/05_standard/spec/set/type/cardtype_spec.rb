# -*- encoding : utf-8 -*-

describe Card::Set::Type::Cardtype do
  describe "add_button view" do
    it "creates link with correct path" do
      add_link = render_content "{{Basic|add_button}}"
      assert_view_select add_link, 'a[href="/new/Basic"]', "Add Basic"
    end
    it "handles title argument" do
      add_link = render_content "{{Basic|add_button;title: custom link text}}"
      assert_view_select add_link, 'a[href="/new/Basic"]', "custom link text"
    end
    it "handles params" do
      add_link = render_content "{{Basic|add_button;params:_project=_self}}"
      assert_view_select add_link, 'a[href="/new/Basic?_project=Tempo+Rary+2"]'
    end
  end
end
