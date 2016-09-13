class Card
  module Set
    # API to inherit other sets and their formats
    module Inheritance
      # include a set module and all its format modules
      # @param [Module] set
      # @param [Hash] opts choose the formats you want to include. You can also
      #    pass arbitrary options to the included set. The option is saved
      #    in the including set. To use the option you need a `included` method
      #    in the included set to fetch the option.
      # @option opts [Symbol, Array<Symbol>] :only include only these formats
      # @option opts [Symbol, Array<Symbol>] :except don't include these formats
      # @example
      #   include_set Type::Basic, except: :css
      # @example pass an option
      #   include_set Type::Name, default_name: "Luke"
      #   default_name           # => "Luke"
      #
      #   def introduce_yourself
      #     puts my_name_is      # => "Luke"
      #   end
      #
      #   # in Type::Name
      #   def self.included host_class
      #     host_class.class_eval do
      #       define_method :my_name_is do |name=nil|
      #         name || host_class.default_name
      #       end
      #     end
      #   end
      #
      def include_set set, opts={}
        opts.each do |key, value|
          cattr_accessor key
          self.send "#{key}=", value
        end

        set_type = set.abstract_set? ? :abstract : :nonbase
        add_set_modules Card::Set.modules[set_type][set.shortname]
        include_set_formats set, opts
      end

      # include format modules of a set
      # @param [Module] set
      # @param [Hash] opts choose the formats you want to include
      # @option opts [Symbol, Array<Symbol>] :only include only these formats
      # @option opts [Symbol, Array<Symbol>] :except don't include these formats
      # @example
      #   include_set_formats Type::Basic, except: :css
      def include_set_formats set, opts={}
        each_format set do |format, format_mods|
          format_sym = Card::Format.format_sym format
          next unless applicable_format?(format_sym, opts[:except], opts[:only])
          format_mods.each do |format_mod|
            define_on_format format_sym do
              include format_mod
            end
          end
        end
      end

      private

      # iterate through each format associated with a set
      def each_format set
        set_type = set.abstract_set? ? :abstract : :nonbase
        format_type = "#{set_type}_format".to_sym
        modules[format_type].each_pair do |format, set_format_mod_hash|
          next unless (format_mods = set_format_mod_hash[set.shortname])
          yield format, format_mods
        end
      end

      def applicable_format? format, except, only
        format_sym = Card::Format.format_sym format
        return false if except && Array(except).include?(format_sym)
        return false if only && !Array(only).include?(format_sym)
        true
      end
    end
  end
end
