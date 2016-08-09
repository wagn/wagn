class Card
  module Set
    # advanced set module API
    module AdvancedApi
      def ensure_set &block
        set_module = yield
      rescue NameError => e
        if e.message =~ /uninitialized constant (?:Card::Set::)?(.+)$/
          constant_pieces = Regexp.last_match(1).split("::")
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
    end
  end
end
