cw_path = File.expand_path "../../../../../vendor/carrierwave/lib", __FILE__
$LOAD_PATH.unshift(cw_path) unless $LOAD_PATH.include?(cw_path)
require "carrierwave"

module CarrierWave
  module CardMount
    include CarrierWave::Mount

    def uploaders
      Card.uploaders ||= {}
    end

    def uploader_options
      Card.uploader_options ||= {}
    end

    def mount_uploader column, uploader=nil, options={}, &block
      options[:mount_on] ||= :db_content
      super

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        event :store_#{column}_event, :finalize, on: :save do
          store_#{column}!
        end

        # remove files only if card has no history
        event :remove_#{column}_event, :finalize,
              on: :delete, when: proc { |c| !c.history? } do
          remove_#{column}!
        end
        event :mark_remove_#{column}_false_event, :finalize,
              on: :update do
          mark_remove_#{column}_false
        end
        event :store_previous_changes_for_#{column}_event, :store,
              on: :update, when: proc { |c| !c.history? } do
          store_previous_changes_for_#{column}
        end
        event :remove_previously_stored_#{column}_event, :finalize,
              on: :update, when: proc { |c| !c.history?} do
          remove_previously_stored_#{column}
        end

        def attachment
          #{column}
        end

        def store_attachment!
          store_#{column}!
        end

        def attachment_name
          "#{column}".to_sym
        end

        def read_uploader *args
          read_attribute *args
        end

        def write_uploader *args
          write_attribute *args
        end

        def #{column}=(new_file)
          return if new_file.blank?
          db_column = _mounter(:#{column}).serialization_column
          send(:"\#{db_column}_will_change!")
          if web?
            self.content = new_file
          else
            send(:"#{column}_will_change!")
            super
          end
        end

        def remote_#{column}_url=(url)
          db_column = _mounter(:#{column}).serialization_column
          send(:"\#{db_column}_will_change!")
          if web?
            self.content = url
          else
            send(:"#{column}_will_change!")
            super
          end
        end

        def remove_#{column}=(value)
          column = _mounter(:#{column}).serialization_column
          send(:"\#{column}_will_change!")
          super
        end

        def remove_#{column}!
          self.remove_#{column} = true
          write_#{column}_identifier
          self.remove_#{column} = false
          super
        end

        def #{column}_will_change!
          @#{column}_changed = true
        end

        def #{column}_changed?
          @#{column}_changed
        end

        def serializable_hash(options=nil)
          hash = {}

          except = options && options[:except] &&
                   Array.wrap(options[:except]).map(&:to_s)
          only   = options && options[:only]   &&
                   Array.wrap(options[:only]).map(&:to_s)

          self.class.uploaders.each do |column, uploader|
            if (!only && !except) || (only && only.include?(column.to_s)) ||
               (!only && except && !except.include?(column.to_s))
              hash[column.to_s] = _mounter(column).uploader.serializable_hash
            end
          end
          super(options).merge(hash)
        end
      RUBY
    end
  end
end
