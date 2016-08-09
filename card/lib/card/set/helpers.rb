class Card
  module Set
    module Helpers
      def shortname
        parts = name.split "::"
        first = 2 # shortname eliminates Card::Set
        pattern_name = parts[first].underscore
        last = if pattern_name == "abstract"
                 first + 1
               else
                 set_class = Card::SetPattern.find pattern_name
                 first + set_class.anchor_parts_count
               end
        parts[first..last].join "::"
      end

      def abstract_set?
        name =~ /^Card::Set::Abstract::/
      end

      def all_set?
        name =~ /^Card::Set::All::/
      end
    end
  end
end
