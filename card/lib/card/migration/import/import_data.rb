class Card
  class Migration
    class Import
      # Handles the card attributes and remotes for the import
      class ImportData
        include CardContent
        include CardAttributes

        # Takes a block to update import data
        # use #add_card and #add_remote in the block to make
        # changes
        def self.update data_path
          data = ImportData.new(data_path)
          yield(data)
          data.write_attributes
        end

        def self.load data_path, opts={}
          data = ImportData.new(data_path)
          if opts[:all]
            data.all_cards
          elsif opts[:only]
            data.select_cards opts[:only]
          else
            data.changed_cards
          end
        end

        def initialize data_path
          @path = File.join data_path, "cards.yml"
          @card_content_dir = File.join data_path, "cards"
          @data = read_attributes
        end

        def all_cards
          cards.map { |data| prepare_for_import data }
        end

        def select_cards names_or_keys
          cards.map do |attributes|
            next unless name_or_key_match attributes, names_or_keys
            prepare_for_import attributes
          end.compact
        end

        def changed_cards
          cards.map do |data|
            next unless changed?(data)
            prepare_for_import data
          end.compact
        end

        # mark as merged
        def merged data, time
          update_attribute data["name"], :merged, time
        end

        # to be used in an update block
        def add_card card_data
          card_attr, card_content = split_attributes_and_content card_data

          update_card_attributes card_attr
          write_card_content card_attr, card_content
          card_attr
        end

        # to be used in an update block
        def add_remote name, url
          remotes[name] = url
        end

        def url remote_name
          remotes[remote_name.to_sym] ||
            raise("unknown remote: #{remote_name}")
        end

        private

        def split_attributes_and_content data
          card_data = {}
          [:name, :type, :codename].each do |key|
            card_data[key] = data[key] if data[key]
          end
          card_data[:key] = data[:name].to_name.key
          [card_data, data[:content]]
        end

        def name_or_key_match attributes, names_or_keys
          names_or_keys.any? do |nk|
            nk == attributes[:name] || nk == attributes[:name].to_name.key ||
              nk == attributes[:key]
          end
        end

        def remotes
          @data[:remotes]
        end

        def cards
          @data[:cards]
        end

        def prepare_for_import data
          hash = card_attributes(data)
          hash[:content] = card_content(data)
          [:file, :image].each do |attach|
            hash[attach] &&= card_attachment(attach, data)
          end
          hash.with_indifferent_access
        end

        def changed? data
          !data[:merged] || content_changed?(data)
        end

        def card_attachment attach_type, data
          Card::Migration.data_path "files/#{data[attach_type]}"
        end
      end
    end
  end
end
