require_dependency "card/view/visibility"
require_dependency "card/view/cache"

class Card
  class View
    include Visibility
    include Cache
    extend Cache::ClassMethods

    # @@string_option_keys = [:view, :type, :title, :variant, :params]

    @@option_keys = ::Set.new [
      :nest_name,   # name as used in nest
      :nest_syntax, # full nest syntax
      :items,      # handles pipe-based recursion

      # _conventional options_
      :view, :type, :title, :params, :variant, :home_view,
      :size,        # images only
      :hide, :show, # affects optional rendering
      :structure    # override raw_content
    ]

    cattr_reader :option_keys
    attr_reader :format

    def initialize format, view, args={}, parent_voo=nil
      @format = format
      @original = view
      @arguments = args
      @parent_voo = parent_voo
    end

    def original_options
      if @parent_voo
        @parent_voo.options.clone.merge @arguments
      else
        @arguments
      end
    end

    def prepare
      return if hide?
      #fetch do
        yield approved, non_option_arguments
        #end
    end

    def requested
      @requested ||= View.canonicalize @original
    end

    def approved
      @approved ||= format.ok_view requested, pre_options
    end

    # default_X_args not yet run
    def pre_options
      @pre_options ||= case (a = original_options.clone)
                       when nil   then {}
                       when Hash  then a
                       when Array then a[0].merge a[1]
                       else raise Card::Error, "bad view args: #{a}"
                       end
    end

    def options
      @options ||= @@option_keys.each_with_object({}) do |key, hash|
        hash[key] = all_arguments[key] if all_arguments[key]
        hash
      end
    end

    def non_option_arguments
      options # make sure options have been processed
      @non_option_arguments ||= all_arguments.reject do |key, _value|
        @@option_keys.member? key
      end
    end

    def all_arguments
      @all_arguments ||=
        format.view_options_with_defaults(approved, pre_options.clone)
    end

    def style
      options[:style]
    end

    @@option_keys.each do |option_key|
      define_method option_key do
        options[option_key]
      end

      define_method "#{option_key}=" do |value|
        options[option_key] = value
      end
    end

  end
end
