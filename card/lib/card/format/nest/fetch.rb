class Card
  class Format
    module Nest
      # Fetch card for a nest
      module Fetch
        def fetch_nested_card cardish, opts={}
          case cardish
          when Card            then cardish
          when Symbol, Integer then Card.fetch cardish
          when "_", "_self"    then card.context_card
          else
            opts[:nest_name] = cardish.to_s
            Card.fetch cardish, new: nest_new_args(opts)
          end
        end

        private

        def nest_new_args nest_opts
          nest_name = nest_opts[:nest_name].to_s
          new_args = { name: nest_name, type: nest_opts[:type] }

          new_args[:supercard] = card.context_card unless nest_name.strip.blank?
          # special case.  gets absolutized incorrectly. fix in smartname?

          nest_new_main_args new_args if nest_name =~ /^_main\+/
          nest_new_content_args new_args, nest_name
          new_args
        end

        def nest_new_main_args new_args
          # FIXME: this is a rather hacky way to get @superleft
          # to work on new cards named _main+whatever
          new_args[:name] = new_args[:name].gsub(/^_main\+/, "+")
          new_args[:supercard] = root.card
        end

        def nest_new_content_args new_args, nest_name
          content = nest_content_from_shorthand_param(nest_name) ||
                    nest_content_from_subcard_params(nest_name)
          new_args[:content] = content if content.present?
        end

        def nest_content_from_shorthand_param nest_name
          shorthand_param = nest_name.tr "+", "_"
          # FIXME: this is a lame shorthand; could be another card's key
          # should be more robust and managed by Card::Name
          params[shorthand_param]
        end

        def nest_content_from_subcard_params nest_name
          return unless (subcard_params = params["subcards"])
          return unless (nestcard_params = subcard_params[nest_name])
          nestcard_params["content"]
        end

      end
    end
  end
end
