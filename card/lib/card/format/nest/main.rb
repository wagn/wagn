class Card
  class Format
    module Nest
      # Handle the main nest
      module Main
        def wrap_main content
          content # no wrapping in base format
        end

        protected

        def main_nest opts
          opts.merge! root.main_opts if root.main_opts
          legacy_main_opts_tweaks! opts

          with_nest_mode :normal do
            @mainline = true
            result = wrap_main nest_card(root.card, opts)
            @mainline = false
            result
          end
        end

        def legacy_main_opts_tweaks! opts
          if (val = params[:size]) && val.present?
            opts[:size] = val.to_sym
          end

          if (val = params[:item]) && val.present?
            opts[:items] = (opts[:items] || {}).reverse_merge view: val.to_sym
          end
        end
      end
    end
  end
end
