# -*- encoding : utf-8 -*-

require_dependency "card/diff"

class Card
  Format.register :html
  class HtmlFormat < Format
    attr_accessor :options_need_save, :start_time, :skip_autosave

    # builtin layouts allow for rescue / testing
    LAYOUTS = Loader.load_layouts.merge "none" => "{{_main}}"

    # helper methods for layout view
    def get_layout_content
      Auth.as_bot do
        if (requested_layout = params[:layout])
          layout_from_card_or_code requested_layout
        else
          layout_from_rule
        end
      end
    end

    def layout_from_rule
      if (rule = card.rule_card(:layout)) && rule.type_id == Card::PointerID &&
         (layout_name = rule.item_names.first)
        layout_from_card_or_code layout_name
      end
    end

    def layout_from_card_or_code name
      layout_card = Card.fetch name.to_s, skip_virtual: true, skip_modules: true
      if layout_card && layout_card.ok?(:read)
        layout_card.content
      elsif (hardcoded_layout = LAYOUTS[name])
        hardcoded_layout
      else
        "<h1>Unknown layout: #{name}</h1>"\
        "Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
      end
    end

    def get_nest_defaults nested_card
      { view: (nested_card.rule(:default_html_view) || :titled) }
    end

    def default_item_view
      :closed
    end

    def html_escape_except_quotes s
      # to be used inside single quotes (makes for readable json attributes)
      s.to_s.gsub(/&/, "&amp;").gsub(/\'/, "&apos;")
       .gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end

    def main?
      if show_layout?
        @depth == 1 && @mainline # assumes layout includes {{_main}}
      else
        @depth.zero? && params[:is_main]
      end
    end

    def focal? # meaning the current card is the requested card
      if show_layout?
        main?
      else
        @depth.zero?
      end
    end
  end
end
