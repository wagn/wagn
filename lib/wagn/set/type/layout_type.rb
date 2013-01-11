module Wagn
  module Set::Type::LayoutType
    include Sets

    format :base

    define_view :editor, :type=>:layout_type do |args|
      form.text_area :content, :rows=>30, :class=>'card-content'
    end

    define_view :core, :type=>:layout_type do |args|
      h _render_raw
    end

    module Model
      def clean_html?
        false
      end
    end
  end
end
