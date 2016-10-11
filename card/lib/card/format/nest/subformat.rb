class Card
  class Format
    module Nest
      module Subformat
        def subformat subcard
          subcard = Card.fetch(subcard, new: {}) if subcard.is_a?(String)
          self.class.new subcard,
                         parent: self, depth: @depth + 1, root: @root,
                         # FIXME: - the following four should not be hard-coded
                         # here.  need a generalized mechanism
                         # for attribute inheritance
                         context_names: @context_names, mode: @mode,
                         mainline: @mainline, form: @form
        end

        def field_subformat field
          field = card.cardname.field(field) unless field.is_a?(Card)
          subformat field
        end


      end
    end
  end
end
