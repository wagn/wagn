class Bootstrap
  class Component
    class Form < Component
      def render_content *args
          form *args, &@build_block
      end

      add_tag_method :form, nil, optional_classes: {
        horizontal: "form-horizontal",
        inline: "form-inline" }
      add_div_method :group, "form-group"
      add_tag_method :label, nil
      add_tag_method :input, "form-control" do |opts, extra_args|
        type, label = extra_args
        prepend { label label, for: opts[:id] } if label
        opts[:type] = type
        opts
      end

      [:text, :password, :datetime, :"datetime-local", :date, :month, :time,
       :week, :number, :email, :url, :search, :tel, :color].each do |tag|
        add_tag_method tag, "form-control", attributes: { type: tag },
                       tag: :input do |opts, extra_args|
          label, = extra_args
          prepend { label label, for: opts[:id] } if label
          opts
        end
      end
    end
  end
end
