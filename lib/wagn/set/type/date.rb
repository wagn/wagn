# -*- encoding : utf-8 -*-
module Wagn
  module Set::Type::Date
    extend Set

    format :html

    # what is this for?  Can't you just use TYPE-date and editor to match this cas, no special view needed?
    define_view :editor, :type=>'date' do |args|
      form.text_field :content, :class=>'date-editor'
    end
  end
end
