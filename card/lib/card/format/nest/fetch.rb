class Card
  class Format
    module Nest
      # Fetch card for a nest
      module Fetch
        def fetch_nested_card name_or_card_or_opts, opts={}
          case name_or_card_or_opts
          when Card
            name_or_card_or_opts
          when Hash
            opts = name_or_card_or_opts
            Card.fetch(opts[:inc_name], new: nest_new_args(opts))
          when Symbol
            Card.fetch(name_or_card_or_opts)
          else
            opts[:inc_name] = name_or_card_or_opts.to_s
            Card.fetch name_or_card_or_opts, new: nest_new_args(opts)
          end
        end

        private

        def nest_content cardname
          content = params[cardname.to_s.tr("+", "_")]

          # CLEANME This is a hack so plus cards re-populate on failed signups
          p = params["subcards"]
          if p && (card_params = p[cardname.to_s])
            content = card_params["content"]
          end
          content if content.present? # returns nil for empty string
        end

        def nest_new_args opts
          args = { name: opts[:inc_name], type: opts[:type], supercard: card }
          args.delete(:supercard) if opts[:inc_name].strip.blank?
          # special case.  gets absolutized incorrectly. fix in smartname?
          if opts[:inc_name] =~ /^_main\+/
            # FIXME: this is a rather hacky (and untested) way to get @superleft
            # to work on new cards named _main+whatever
            args[:name] = args[:name].gsub(/^_main\+/, "+")
            args[:supercard] = root.card
          end
          if (content = nest_content opts[:inc_name])
            args[:content] = content
          end
          args
        end
      end
    end
  end
end
