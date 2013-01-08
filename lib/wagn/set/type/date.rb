module Wagn
  module Set
    module Type
      module Date
        include Sets

        format :html

        # what is this for?  Can't you just use TYPE-date and editor to match this cas, no special view needed?
        define_view :editor, :type=>'date' do |args|
          form.text_field :content, :class=>'date-editor'
        end
      end
    end
  end
end
