#require 'component'

class Bootstrap
  module BasicTags
    def html content
      add_content String(content).html_safe
      ""
    end

    Component.add_div_method :div, nil do |opts, extra_args|
      prepend_class opts, extra_args.first if extra_args.present?
      opts
    end

    Component.add_div_method :span, nil do |opts, extra_args|
      prepend_class opts, extra_args.first if extra_args.present?
      opts
    end

    Component.add_tag_method :tag, nil, tag: :yield do |opts, extra_args|
      prepend_class opts, extra_args[1] if extra_args[1].present?
      opts[:tag] = extra_args[0]
      opts
    end
  end
end
