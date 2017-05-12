class Card
  class Format
    module Names
      def initial_context_names
        @initial_context_names ||=
          if @context_names
            context_names_minus_irrelevants
          else
            context_names_from_params
          end
      end

      def context_names_minus_irrelevants
        part_keys = @card.cardname.part_names.map(&:key)
        @context_names.reject { |n| !part_keys.include? n.key }
      end

      def context_names_from_params
        return [] unless (name_list = Card::Env.slot_opts[:name_context])
        name_list.to_s.split(",").map(&:to_name)
      end

      def context_names_to_params
        return unless @context_names
        @context_names.join(",")
      end

      def add_name_context name=nil
        name ||= card.name
        @context_names += name.to_name.part_names
        @context_names.uniq!
      end

      def showname title=nil
        if title
          card.cardname.title title, @context_names
        else
          @showname ||= card.cardname.to_show(*@context_names)
        end
      end
    end
  end
end
