module Wagn
  module Set::All::EmailHtml
    include Sets

    format :email

    define_view :missing        do |args| '' end
    define_view :closed_missing do |args| '' end
  end
end
