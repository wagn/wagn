# -*- encoding : utf-8 -*-
module Wagn
  module Set::Type::LayoutType
    extend Set

    format :base

    view :editor, :type=>:layout_type do |args|
      form.text_area :content, :rows=>15, :class=>'card-content'
    end

    view :core, :type=>:layout_type do |args|
      h _render_raw
    end

    module Model
      def clean_html?
        false
      end
    end
  end
end
