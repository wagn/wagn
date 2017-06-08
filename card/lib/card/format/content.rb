class Card
  class Format
    module Content
      def process_content override_content=nil, opts={}
        content = override_content || render_raw || ""
        content_object = get_content_object content, opts
        content_object.process_each_chunk do |chunk_opts|
          content_nest chunk_opts.merge(opts)
        end
        content_object.to_s
      end

      def get_content_object content, opts
        if content.is_a? Card::Content
          content
        else
          Card::Content.new content, self, opts.delete(:content_opts)
        end
      end

      def format_date date, include_time=true
        # using DateTime because Time doesn't support %e on some platforms
        if include_time
          # .strftime('%B %e, %Y %H:%M:%S')
          I18n.localize(DateTime.new(date.year, date.mon, date.day,
                                     date.hour, date.min, date.sec),
                        format: :card_date_seconds)
        else
          # .strftime('%B %e, %Y')
          I18n.localize(DateTime.new(date.year, date.mon, date.day),
                        format: :card_date_only)
        end
      end

      def add_class options, klass
        options[:class] = css_classes options[:class], klass
      end

      alias_method :append_class, :add_class

      def prepend_class options, klass
        options[:class] = css_classes klass, options[:class]
      end

      def css_classes *array
        array.flatten.uniq.compact * " "
      end

      def id_counter
        return @parent.id_counter if @parent
        @id_counter ||= 0
        @id_counter += 1
      end

      def unique_id
        "#{card.cardname.safe_key}-#{id_counter}"
      end

      def output *content
        content = yield if block_given?
        Array.wrap(content).flatten.compact.join "\n"
      end
    end
  end
end
