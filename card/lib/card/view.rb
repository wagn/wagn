require_dependency "card/view/visibility"
require_dependency "card/view/cache"

class Card
  class View
    include Visibility
    include Cache
    extend Cache::ClassMethods

    @@string_option_keys = [
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

    @@hash_option_keys = [
      :items        # handles pipe-based recursion
    ]

    @@array_option_keys = [
      :hide, :show  # affect optional rendering
    ]

    @@standard_option_keys = @@string_option_keys + @@hash_option_keys
    @@option_keys = @@standard_option_keys + @@array_option_keys

    cattr_reader :option_keys
    attr_reader :format

    def initialize format, view, args={}, parent_voo=nil
      @format = format
      @original = view
      @original_args = args
      @parent_voo = parent_voo
      options
    end


    def prepare
      return if hide?
      #fetch do
        yield approved, sanitized_live_args
        #end
    end


    def requested
      @requested ||= View.canonicalize @original
    end

    def approved
      @approved ||= format.ok_view requested, live_args
    end

    # default_X_args not yet run
    def clean_args
      @clean_args ||= case (a = @original_args.clone)
                      when nil   then {}
                      when Hash  then a
                      when Array then a[0].merge a[1]
                      else raise Card::Error, "bad view args: #{a}"
                      end
    end

    def refreshed_options
      @options = nil
      options
    end

    def options
      return @options if @options
      @options = standard_options_from_args_and_parent
      process_visibility_options
      @options
    end

    def standard_options_from_args_and_parent
      @@standard_option_keys.each_with_object({}) do |key, hash|
        value = live_args.delete(key)
        value ||= @parent_voo.options[key] if @parent_voo
        hash[key] = value if value
        hash
      end
    end

    def sanitized_live_args
      live_args.reject do |key, _value|
        @@option_keys.member? key
      end
    end

    def live_args
      @live_args ||=
        format.view_options_with_defaults(requested, clean_args.clone)
    end

    def style
      options[:style]
    end

    def items
      options[:items] ||= {}
    end

    @@string_option_keys.each do |option_key|
      define_method option_key do
        options[option_key]
      end

      define_method "#{option_key}=" do |value|
        options[option_key] = value
      end
    end



  end
end
