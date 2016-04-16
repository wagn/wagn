class Card
  module Set
    # ActiveCard support: accessing plus cards as attributes
    module Trait
      def card_accessor *args
        options = args.extract_options!
        add_traits args, options.merge(reader: true, writer: true)
      end

      def card_reader *args
        options = args.extract_options!
        add_traits args, options.merge(reader: true)
      end

      def card_writer *args
        options = args.extract_options!
        add_traits args, options.merge(writer: true)
      end

      private

      def add_attributes *args
        Card.set_specific_attributes ||= []
        Card.set_specific_attributes += args.map(&:to_s)
      end

      def get_traits mod
        Card::Set.traits ||= {}
        Card::Set.traits[mod] || Card::Set.traits[mod] = {}
      end

      def add_traits args, options
        mod = self
        mod_traits = get_traits mod

        new_opts = options[:type] ? { type: options[:type] } : {}
        new_opts[:default_content] = options[:default] if options[:default]

        args.each do |trait|
          define_trait_card trait, new_opts
          define_trait_reader trait if options[:reader]
          define_trait_writer trait if options[:writer]

          mod_traits[trait.to_sym] = options
        end
      end

      def define_trait_card trait, opts
        define_method "#{trait}_card" do
          trait_var "@#{trait}_card" do
            fetch trait: trait.to_sym, new: opts.clone
          end
        end
      end

      def define_trait_reader trait
        define_method trait do
          trait_var "@#{trait}" do
            send("#{trait}_card").content
          end
        end
      end

      def define_trait_writer trait
        define_method "#{trait}=" do |value|
          card = send "#{trait}_card"
          subcards.add name: card.name, type_id: card.type_id, content: value
          instance_variable_set "@#{trait}", value
        end
      end
    end
  end
end
