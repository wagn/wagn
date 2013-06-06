# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::EmailHtml
    extend Sets

    format :email

    define_view :missing        do |args| '' end
    define_view :closed_missing do |args| '' end
  end
end
