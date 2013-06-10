# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::Text
    extend Set

    format :text

    view :core do |args|
      HTMLEntities.new.decode strip_tags( process_content _render_raw )
    end
  end
end
