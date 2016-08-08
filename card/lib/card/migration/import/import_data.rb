class Card
  class Migration
    class Import
      # Handles the card attributes and remotes for the import
      class ImportData
        DEFAULT_PATH = Card::Migration.data_path("cards.yml").freeze
        CARD_CONTENT_DIR = Card::Migration.data_path("cards").freeze

        class << self
          def update
            data = ImportData.new
            yield(data)
            data.write
          end

          def all_cards
            ImportData.new.all_cards
          end

          def changed_cards
            ImportData.new.changed_cards
          end
        end

        def initialize path=nil
          @path = path || DEFAULT_PATH
          ensure_path
          @data = read
        end

        def all_cards
          cards.map { |data| prepare_for_import data }
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

        def add_card new_attr
          card_data = {}
          [:name, :type, :codename].each do |key|
            card_data[key] = new_attr[key] if new_attr[key]
          end
          card_data[:key] = new_attr[:name].to_name.key
          card_entry = find_card card_data[:name]

          if card_entry
            card_entry.replace card_data
          else
            cards << card_data
          end
          write_card_content card_data, new_attr[:content]
          card_data
        end

        def add_remote name, url
          @data[:remotes][name] = url
        end

        def url remote_name
          @data[:remotes][remote_name.to_sym] ||
            raise("unknown remote: #{remote_name}")
        end

        def read
          return { cards: [], remotes: {} } unless File.exist? @path
          YAML.load_file(@path).deep_symbolize_keys
        end

        def write
          File.write @path, @data.to_yaml
        end

        private

        def update_attribute name, attr_key, attr_value
          card = find_card name
          return unless card
          card[attr_key] = attr_value
          card
        end

        def cards
          @data[:cards]
        end

        def prepare_for_import data
          card_attr = ::Set.new [:name, :type, :codename, :file, :image]
          hash = data.select { |k, v| v && card_attr.include?(k) }
          hash[:content] = File.read(content_path(data))
          [:file, :image].each do |attach|
            hash[attach] &&= Card::Migration.data_path "files/#{hash[attach]}"
          end
          hash.with_indifferent_access
        end

        def changed? data
          !data[:merged] ||
            Time.parse(data[:merged]) < File.mtime(content_path(data))
        end

        def write_card_content data, content
          FileUtils.mkpath CARD_CONTENT_DIR unless Dir.exist? CARD_CONTENT_DIR
          File.write content_path(data), content.to_s
        end

        def content_path data
          filename = data[:key] || data[:name].to_name.key
          File.join CARD_CONTENT_DIR, filename
        end

        def find_card name
          key = name.to_name.key
          index = cards.find_index { |attr| attr[:key] == key } ||
                  cards.find_index { |attr| attr[:name] == name }
          return unless index
          cards[index]
        end

        def ensure_path
          dir = File.dirname(@path)
          FileUtils.mkpath dir unless Dir.exist? dir
        end
      end
    end
  end
end
