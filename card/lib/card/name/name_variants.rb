class Card
  class Name
    module NameVariants
      @@variant_methods = [:capitalize, :singularize, :pluralize, :titleize,
                           :downcase, :upcase, :swapcase, :reverse, :succ]
      @@variant_aliases = { capitalized: :capitalize, singular: :singularize,
                            plural: :pluralize,       title: :titleize }

      def vary variants
        variants.to_s.split(/[\s,]+/).inject(self.s) do |name, variant|
          variant = @@variant_aliases[variant.to_sym] || variant.to_sym
          @@variant_methods.include?(variant) ? name.send(variant) : name
        end
      end
    end
  end
end
