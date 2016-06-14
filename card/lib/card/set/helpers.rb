class Card
  module Set
    # advanced set module API
    module Helpers
      # include a set module and all its format modules
      # @param [Module] set
      # @param [Hash] opts choose the formats you want to include
      # @option opts [Symbol, Array<Symbol>] :only include only these formats
      # @option opts [Symbol, Array<Symbol>] :except don't include these formats
      # @example
      # include_set Type::Basic, except: :css
      def include_set set, opts={}
        set_type = set.abstract_set? ? :abstract : :nonbase
        Card::Set.modules[set_type][set.shortname].each do |set_mod|
          include set_mod
        end
        include_set_formats set, opts
      end

      # include a format modules of a set
      # @param [Module] set
      # @param [Hash] opts choose the formats you want to include
      # @option opts [Symbol, Array<Symbol>] :only include only these formats
      # @option opts [Symbol, Array<Symbol>] :except don't include these formats
      # @example
      # include_set Type::Basic, except: :css
      def include_set_formats set, opts={}
        each_format set do |format, format_mods|
          match = format.to_s.match(/::(?<format>[^:]+)Format/)
          format_sym = match ? match[:format] : :base
          next unless applicable_format?(format_sym, opts[:except], opts[:only])
          format_mods.each do |format_mod|
            define_on_format format_sym do
              include format_mod
            end
          end
        end
      end

      def ensure_set &block
        set_module = yield
      rescue NameError => e
        if e.message =~ /uninitialized constant (?:Card::Set::)?(.+)$/
          constant_pieces = Regexp.last_match(1).split('::')
          constant_pieces.inject(Card::Set) do |set_mod, module_name|
            set_mod.const_get_or_set module_name do
              Module.new
            end
          end
        end
        # try again - there might be another submodule that doesn't exist
        ensure_set(&block)
      else
        set_module.extend Card::Set
      end

      def attachment name, args
        include Abstract::Attachment
        add_attributes name, "remote_#{name}_url".to_sym, :load_from_mod,
                       :action_id_of_cached_upload, :empty_ok
        uploader_class = args[:uploader] || FileUploader
        mount_uploader name, uploader_class
      end

      def stage_method method, opts={}, &block
        class_eval do
          define_method "_#{method}", &block
          define_method method do |*args|
            if (error = wrong_stage(opts) || wrong_action(opts[:on]))
              raise Card::Error, error
            else
              send "_#{method}", *args
            end
          end
        end
      end

      def shortname
        parts = name.split '::'
        first = 2 # shortname eliminates Card::Set
        pattern_name = parts[first].underscore
        last = if pattern_name == 'abstract'
                 first + 1
               else
                 set_class = Card::SetPattern.find pattern_name
                 first + set_class.anchor_parts_count
               end
        parts[first..last].join '::'
      end

      def abstract_set?
        name =~ /^Card::Set::Abstract::/
      end

      def all_set?
        name =~ /^Card::Set::All::/
      end
    end
  end
end
