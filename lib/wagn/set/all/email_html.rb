# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::EmailHtml
    extend Set

    format :email

    view :missing        do |args| '' end
    view :closed_missing do |args| '' end
  end
end
