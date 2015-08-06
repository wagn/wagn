require 'carrierwave'

module CarrierWave
  module CardMount
    include CarrierWave::Mount


    def uploaders
      Card.uploaders ||= {}
    end

    def uploader_options
      Card.uploader_options ||= {}
    end

    def mount_uploader(column, uploader=nil, options={}, &block)
      options[:mount_on] ||= :db_content
      super

      class_eval <<-RUBY, __FILE__, __LINE__+1
        event :store_#{column}_event, :on=>:save, :after =>:write_identifier  do
          store_#{column}!
        end
        event :remove_#{column}_event, :on =>:delete, :after=>:stored do
          remove_#{column}!
        end
        event :mark_remove_#{column}_false_event, :on => :update, :after=>:stored do
          mark_remove_#{column}_false
        end
        event :store_previous_model_for_#{column}_event, :on=>:update, :before =>:store do
          store_previous_model_for_#{column}
        end

        def attachment
          #{column}
        end

        def read_uploader *args
          read_attribute *args
        end
        def write_uploader *args
          write_attribute *args
        end
        def #{column}=(new_file)
          column = _mounter(:#{column}).serialization_column
          send(:"\#{column}_will_change!")
          super
        end

        def remote_#{column}_url=(url)
          column = _mounter(:#{column}).serialization_column
          send(:"\#{column}_will_change!")
          super
        end

        def remove_#{column}!
          super
          _mounter(:#{column}).remove = true
          _mounter(:#{column}).write_identifier
        end

        def serializable_hash(options=nil)
          hash = {}

          except = options && options[:except] && Array.wrap(options[:except]).map(&:to_s)
          only   = options && options[:only]   && Array.wrap(options[:only]).map(&:to_s)

          self.class.uploaders.each do |column, uploader|
            if (!only && !except) || (only && only.include?(column.to_s)) || (!only && except && !except.include?(column.to_s))
              hash[column.to_s] = _mounter(column).uploader.serializable_hash
            end
          end
          super(options).merge(hash)
        end
      RUBY
    end

  end
end