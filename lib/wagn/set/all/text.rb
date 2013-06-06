# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::Text
    extend Sets

    format :text

    define_view :core do |args|
      HTMLEntities.new.decode strip_tags( process_content _render_raw )
    end
  end
end
