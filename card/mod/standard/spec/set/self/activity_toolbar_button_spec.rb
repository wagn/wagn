# -*- encoding : utf-8 -*-

describe Card::Set::Self::ActivityToolbarButton do
  subject do
    render_view :edit, name: "A"
  end

  it "is rendered in toolbar" do
    is_expected.to include "activity"
  end

  it "can be hidden with read rule" do
    Card::Auth.as_bot do
      ensure_card %i[activity_toolbar_button self read],
                  content: "Administrator"
    end

    with_user "Joe User" do
      is_expected.not_to include "activity"
    end
  end
end
