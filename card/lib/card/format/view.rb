class Card::Format
  module View
    def view_for_unknown _view, _args
      # note: overridden in HTML
      focal? ? :not_found : :missing
    end

    def canonicalize_view view
      return if view.blank?
      view_key = view.to_viewname.key.to_sym
      DEPRECATED_VIEWS[view_key] || view_key
    end

    def view_in_edit_mode homeview, nested_card
      not_in_form =
        Card::Format.perms[homeview] == :none || # view configured not to keep in form
        nested_card.structure || #      not yet nesting structures
        nested_card.key.blank? #        eg {{_self|type}} on new cards

      not_in_form ? :blank : :edit_in_form
    end

    def view_in_closed_mode homeview, nested_card
      approved_view = Card::Format.closed[homeview]
      case
      when approved_view == true  then homeview
      when Card::Format.error_code[homeview] then homeview
      when approved_view          then approved_view
      when !nested_card.known?    then :closed_missing
      else                             :closed_content
      end
    end

    def default_item_view
      :name
    end
  end
end