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

      :view,
      :structure,
      :type,
      :title,
      :variant,
      :params,
      :home_view,
      :size
    ]

    @@hash_options = [
      :items        # handles pipe-based recursion
    ]

    @@array_options = [
      :hide, :show  # affect optional rendering
    ]

    @@string_options = @@standard_options << :view
    @@options = @@string_options + @@array_options + @@hash_options

    cattr_reader :options
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
        yield approved, non_standard_options
      end
    end

    def original_view
      @original_view ||= View.canonicalize @raw_view
    end

    def approved
      @approved ||= @format.ok_view original_view, live_options
    end

    def normalized_options
      @normalized_options ||= case (raw = @raw_options.clone)
                              when nil   then {}
                              when Hash  then raw
                              when Array then raw[0].merge raw[1]
                              else raise Card::Error, "bad view options: #{raw}"
                              end
    end

    def refreshed_options
      @options = nil
      options
    end

    def options
      return @options if @options
      @options = standard_options_with_inheritance
      process_visibility_options
      @options
    end

    def standard_options_with_inheritance
      @@standard_options.each_with_object({}) do |key, hash|
        value = live_options.delete key
        value ||= @parent_voo.options[key] if @parent_voo
        hash[key] = value if value
        hash
      end
    end

    def non_standard_options
      live_options.reject do |key, _value|
        @@options.member? key
      end
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
