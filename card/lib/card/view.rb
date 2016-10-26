require_dependency "card/view/visibility"
require_dependency "card/view/cache"

class Card
  class View
    include Visibility
    include Cache
    extend Cache::ClassMethods

    @@standard_options = [
      :nest_name,   # name as used in nest
      :nest_syntax, # full nest syntax

      :structure,
      :type,
      :title,
      :variant,
      :params,
      :home_view,
      :size,

      :skip_permissions
    ]

    @@standard_inheritance_options = @@standard_options + [
      :items
    ]

    @@other_options = [
      :view,
      :hide, :show  # affect optional rendering
    ]

    cattr_reader :options, :nest_options

    class << self
      def options
        @options ||= @@standard_inheritance_options + @@other_options
      end

      def nest_options
        @nest_options ||= options.reject { |o| o == :skip_permissions }
      end
    end


    attr_reader :format

    def initialize format, view, raw_options={}, parent_voo=nil
      @format = format
      @card = @format.card
      @raw_view = view
      @raw_options = raw_options
      @parent_voo = parent_voo
      options
    end

    def prepare
      return if hide?
      fetch do
        yield ok_view, foreign_options
      end
    end

    def original_view
      @original_view ||= View.canonicalize @raw_view
    end

    def ok_view
      @ok_view ||=
        @format.ok_view original_view, options[:skip_permissions]
    end

    def normalized_options
      @normalized_options ||= begin
        opts = options_to_hash @raw_options.clone
        opts[:view] = original_view
        opts
      end
    end

    def options_to_hash opts
      case opts
      when Hash  then opts
      when Array then opts[0].merge opts[1]
      when nil   then {}
      else raise Card::Error, "bad view options: #{opts}"
      end
    end

    # def refreshed_options
    #   @options = nil
    #   options
    # end

    def options
      return @options if @options
      @options = standard_options_with_inheritance
      process_visibility_options
      @options
    end

    def standard_options_with_inheritance
      @@standard_inheritance_options.each_with_object({}) do |key, hash|
        value = live_options.delete key
        value ||= @parent_voo.options[key] if @parent_voo
        hash[key] = value if value
        hash
      end
    end

    def foreign_options
      live_options.reject { |key, _value| self.class.options.member? key }
    end

    # run default_X_args
    def live_options
      @live_options ||= @format.view_options_with_defaults(
        original_view, normalized_options.clone
      )
    end

    def items
      options[:items] ||= {}
    end

    @@standard_options.each do |option_key|
      define_method option_key do
        options[option_key]
      end

      define_method "#{option_key}=" do |value|
        options[option_key] = value
      end
    end
  end
end
