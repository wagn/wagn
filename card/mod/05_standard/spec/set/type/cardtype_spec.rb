# -*- encoding : utf-8 -*-

describe Card::Set::Type::Cardtype do
  describe 'add_button view' do

    it 'has the right path' do
      button = render_content "{{Basic|add_button}}"
      debug_assert_view_select button, 'a[href=/new/Basic]'
    end

  end
end
