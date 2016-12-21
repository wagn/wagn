class Card
  class Format
    module Names
      def initial_context_names
        @initial_context_names ||=
          if @context_names
            context_names_minus_irrelevants
          elsif params[:slot]
            context_names_from_params
          else
            []
          end
      end

      def context_names_minus_irrelevants
        part_keys = @card.cardname.part_names.map(&:key)
        @context_names.reject { |n| !part_keys.include? n.key }
      end

      def context_names_from_params
        context_name_list = params[:slot][:name_context].to_s
        context_name_list.split(",").map(&:to_name)
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

      # def with_name_context name
      #   old_context = @context_names
      #   add_name_context name
      #   result = yield
      #   @context_names = old_context
      #   result
      # end

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
