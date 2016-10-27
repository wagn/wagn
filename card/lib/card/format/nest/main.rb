class Card
  class Format
    module Nest
      # Handle the main nest
      module Main
        def wrap_main
          yield # no wrapping in base format
        end

        def main_nest opts
          wrap_main do
            with_nest_mode :normal do
              nest root.card, opts.merge(main: true)
            end
          end
        end

        def main_nest? nest_name
          nest_name == "_main" && !root.already_mained?
        end

        def already_mained?
          return true if @main || @already_main
          @already_main = true
          false
        end

        def main!
          @main = true
        end

        def main_nest_options
          opts = root.main_opts || {}
          main_nest_size_opt opts
          main_nest_items_opt opts
          opts
        end

        protected

        def main_nest_size_opt opts
          val = params[:size]
          return unless val.present?
          opts[:size] = val.to_sym
        end

        def main_nest_items_opt opts
          val = params[:item]
          return unless val.present?
          opts[:items] ||= {}
          opts[:items][:view] = val.to_sym
        end
      end
    end
  end
end
