module CoreExtensions
  module Hash
    module ClassMethods
      # FIXME: this is too ugly and narrow for a core extension.
      def new_from_semicolon_attr_list attr_string
        return {} if attr_string.blank?
        attr_string.strip.split(';').inject({}) do |result, pair|
          value, key = pair.split(':').reverse
          key ||= 'view'
          key.strip!
          value.strip!
          result[key.to_sym] = value
          result
        end
      end

      # create hash with default nested structures
      # @example
      #   h = Hash.new_nested Hash, Array
      #   h[:a] # => {}
      #   h[:b][:c] # => []
      def new_nested *structure
        initialize_nested structure.unshift Hash
      end

      def initialize_nested classes
        klass = classes.shift
        if classes.empty?
          klass.new
        else
          klass.new do |h, k|
            h[k] = initialize_nested classes
          end
        end
      end
    end

    module Merging
      # attach CSS classes
      # @example
      #  {}.css_merge({:class => "btn"}) # => {:class=>"btn"}
      #
      #  h = {:class => "btn"} # => {:class=>"btn"}
      #  h.css_merge({:class => "btn-primary"}) # => {:class=>"btn
      # btn-primary"}
      def css_merge other_hash, separator=' '
        merge(other_hash) do |key, old, new|
          key == :class ? old.to_s + separator + new.to_s : new
        end
      end

      def css_merge! other_hash, separator=' '
        merge!(other_hash) do |key, old, new|
          key == :class ? old.to_s + separator + new.to_s : new
        end
      end

      # merge string values with `separator`
      def string_merge other_hash, separator=' '
        merge(other_hash) do |_key, old, new|
          old.is_a?(String) ? old + separator + new.to_s : new
        end
      end

      def string_merge! other_hash, separator=' '
        merge!(other_hash) do |_key, old, new|
          old.is_a?(String) ? old + separator + new.to_s : new
        end
      end
    end
  end
end
