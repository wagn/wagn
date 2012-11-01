module Wagn::Set::Type::Date
  class Wagn::Views
    format :base

    define_view :editor, :type=>'date' do |args|
      form.text_field :content, :class=>'date-editor'
    end
  end
end
