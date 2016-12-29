class Bootstrap
  class Component
    class HorizontalForm < Form
      def left_col_width
        @child_args.last && @child_args.last[0] || 2
      end

      def right_col_width
        @child_args.last && @child_args.last[1] || 10
      end

      add_tag_method :form, "form-horizontal"

      add_tag_method :label, "control-label" do |opts, extra_args|
        prepend_class opts, "col-sm-#{left_col_width}"
        opts
      end

      add_div_method :input, nil do |opts, extra_args|
        type, label = extra_args
        prepend { tag :label, nil, for: opts[:id] } if label
        insert { inner_input opts.merge(type: type) }
        { class: "col-sm-#{right_col_width}" }
      end
      add_tag_method :inner_input, "form-control", tag: :input
      add_div_method :inner_checkbox, "checkbox"

      add_div_method :checkbox, nil do |opts, extra_args|
        inner_checkbox do
          label do
            inner_input "checkbox", extra_args.first, opts
          end
        end
        { class: "col-sm-offset-#{left_col_width} col-sm-#{right_col_width}" }
      end
    end
  end
end
