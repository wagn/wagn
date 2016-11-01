class Card
  class Format
    module Registration
      def register format
        registered << format.to_s
      end

      def format_class_name format
        format = format.to_s
        format = "" if format == "base"
        format = aliases[format] if aliases[format]
        "#{format.camelize}Format"
      end

      def format_sym format
        return format if format.is_a? Symbol
        match = format.to_s.match(/::(?<format>[^:]+)Format/)
        match ? match[:format] : :base
      end

      def interpret_view_opts view, opts
        extract_class_vars view, opts
        extract_view_tags view, opts.delete(:tags)
      end

      def extract_class_vars view, opts
        [:perms, :error_code, :denial, :closed].each do |varname|
          next unless (value = opts.delete varname)
          send(varname)[view] = value
        end
      end

      def extract_view_tags view, tags
        return unless tags
        Array.wrap(tags).each do |tag|
          view_tags[view] ||= {}
          view_tags[view][tag] = true
        end
      end

      def view_cache_setting_method view
        "view_#{view}_cache_setting"
      end

      def new card, opts={}
        if self != Format
          super
        else
          format = opts[:format] || :html
          klass = class_from_name format_class_name(format)
          self == klass ? super : klass.new(card, opts)
        end
      end

      def class_from_name formatname
        if formatname == "Format"
          Card::Format
        else
          Card::Format.const_get formatname
        end
      end

      def tagged view, tag
        return unless view && tag && (viewhash = view_tags[view.to_sym])
        viewhash[tag.to_sym]
      end

      def format_ancestry
        ancestry = [self]
        ancestry += superclass.format_ancestry unless self == Card::Format
        ancestry
      end
    end
  end
end
