class Card
  class Name
    # Name-based "Fields" are compound names in which the right name is treated
    # as an attribute of the left.  (Eg MyName+address)
    #
    # "Traits" are the subset of fields in which the right name corresponds to a
    # card with a codename
    module FieldsAndTraits
      # @return [String]
      def field tag_name
        field_name(tag_name).s
      end

      # @return [Card::Name]
      def field_name tag_name
        case tag_name
        when Symbol
          trait_name tag_name
        else
          tag_name = tag_name.to_s[1..-1] if tag_name.to_s[0] == "+"
          [self, tag_name].to_name
        end
      end

      # @return [True/False]
      def field_of? context
        if context.present?
          child_of?(context) && relative_name(context).length == 2
          # junction? &&
          #  absolute_name(context).left_name.key == context.to_name.key
          # @child_of?(context_name) && relative_name(context_name).length == 2
        else
          s.match(/^\s*\+[^+]+$/).present?
        end
      end

      def relative_field_name tag_name
        field_name(tag_name).relative_name self
      end

      # @return [String]
      def trait tag_code
        name = trait_name tag_code

        name.s
      end

      # @return [Card::Name]
      def trait_name tag_code
        card_id = Card::Codename[tag_code]
        raise Card::Error::NotFound, "unknown codename: #{tag_code}" unless card_id
        [self, Card.quick_fetch(card_id).name].to_name
      end

      # @return [True/False]
      def trait_name? *traitlist
        junction? && begin
          right_key = right_name.key
          traitlist.find do |codename|
            (card_id = Card::Codename[codename]) &&
              (card = Card.quick_fetch card_id) &&
              card.key == right_key
          end.present?
        end
      end
    end
  end
end
