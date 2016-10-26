require_dependency "card/view/visibility"
require_dependency "card/view/cache"

class Card
  class View
    include Visibility
    include Cache
    extend Cache::ClassMethods

    @@standard_options = ::Set.new [
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
        @options ||= ::Set.new(@@standard_inheritance_options + @@other_options)
      end

      def nest_options
        @nest_options ||= (options - [:main, :skip_permissions])
      end
    end

    attr_reader :format, :parent

    def initialize format, view, raw_options={}, parent=nil
      @format = format
      @card = @format.card
      @raw_view = view
      @raw_options = raw_options
      @parent = parent
      @main = normalized_options.delete :main
    end

    def prepare
      options
      return if optional? && hide?(ok_view)
      fetch do
        yield ok_view, foreign_options
      end
    end

    def original_view
      @original_view ||= View.canonicalize(@raw_view)
    end

    def requested_view
      @requested_view ||=
        View.canonicalize(live_options[:view] || original_view)
    end

    def ok_view
      @ok_view ||=
        @format.ok_view requested_view, options[:skip_permissions]
    end

    def normalized_options
      @normalized_options ||= begin
        options = options_to_hash @raw_options.clone
        options[:view] = original_view
        options
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
      @options = {}
      standard_options_with_inheritance
      main_nest_options
      process_visibility_options
      @options
    end

    def root_main?
      @main
    end

    def standard_options_with_inheritance
      @@standard_inheritance_options.each do |key|
        value = live_options.delete key
        value ||= @parent.options[key] if @parent
        options[key] = value if value
      end
    end

    def main_nest_options
      return {} unless root_main?
      @format.main_nest_options
    end

    def foreign_options
      live_options.reject { |key, _value| self.class.options.member? key }
    end

    # run default_X_args
    def live_options
      return @live_options if @live_options
      live_options ||= @format.view_options_with_defaults(
        original_view, normalized_options.clone
      )
      live_options.merge! main_nest_options
      @live_options = live_options
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
