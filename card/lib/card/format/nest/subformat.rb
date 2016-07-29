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

        private

        def nest_subformat nested_card, opts
          return self if opts[:inc_name] =~ /^_(self)?$/
          sub = subformat nested_card
          sub.nest_opts = opts[:items] ? opts[:items].clone : {}
          sub
        end
      end
    end
  end
end
