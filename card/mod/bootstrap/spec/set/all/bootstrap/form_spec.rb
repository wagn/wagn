# -*- encoding : utf-8 -*-

describe Card::Set::All::Bootstrap::Form  do
  describe "input" do
    it "has form-group css class" do
      assert_view_select render_editor("Phrase"),
                         'input[type="text"][class~="form-control"]'
    end
  end

  describe "textarea" do
    it "has form-group css class" do
      assert_view_select render_editor("Plain Text"),
                         'textarea[class~="form-control"]'
    end
  end

  describe "form" do
    subject { Card["A"].format(:html) }
    it "creates form" do
      form =
        subject.bs_form do
          group do
            input "email", "Email Address", id: "theemail"
            input "password", "Password", id: "thepassword"
          end
        end
      assert_view_select form, 'form' do
        assert_select 'div[class="form-group"]' do
          assert_select 'label[for="theemail"', text: "Email Address"
          assert_select 'input[type="email",id="theemail",class="form-control"]'
        end
      end
    end
  end

  describe "horizontal form" do
    subject { Card["A"].format(:html) }
    it "creates form" do
      form =
        subject.bs_horizontal_form 2, 10 do
          group do
            input "email", "Email Address", id: "theemail"
            input "password", "Password", id: "thepassword"
          end
          group do
            checkbox "test", "checkbox label", id: "thecheckbox"
          end
        end
      assert_view_select form, 'form[class="form-horizontal"]' do
        assert_select 'div[class="form-group"]' do
          assert_select 'label[for="theemail"', text: "Email Address"
          assert_select 'div[class="col-sm-10"]' do
            assert_select 'input[type="email",id="theemail",class="form-control"]'
          end
        end
      end
    end
  end
end
