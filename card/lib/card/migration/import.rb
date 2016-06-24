class Card
  class Migration
    # Imports card data from a local or remote deck
    #
    # The cards' content for the import is stored for every card in a separate
    # file, other attributes like name or type are stored for all cards together
    # in a json file.
    #
    # To update a card's content you only have to change the card's content
    # file. The merge method will recognize that the file was changed
    # since the last merge and merge it into the cards table
    # To update other attributes change them in the json file and either remove
    # the 'pushed' value or touch the content file
    class Import
      CARD_CONTENT_DIR = Card::Migration.data_path('cards').freeze
      OUTPUT_FILE = Card::Migration.data_path 'unmerged'
      class << self
        # Merge the import data into the cards table
        # If 'all' is true all import data is merged.
        # Otherwise only the data that was changed or added since the last merge
        def merge all=false
          merge_data = card_data_for_merge all
          puts('nothing to merge') && return if merge_data.empty?

          Card::Mailer.perform_deliveries = false
          Card::Auth.as_bot do
            Card.merge_list merge_data, output_file: OUTPUT_FILE
          end
          update_time = Time.now
          MetaData.update do |meta_data|
            merge_data.each do |card_attr|
              meta_data.add_card_attribute card_attr['name'], :pushed,
                                           update_time
            end
          end
        end

        # Get import data from a deck
        # @param [String] name The name of the card to be imported
        # @param [Hash] opts pull options
        # @option opts [String] remote Use a remote url. The remote url must
        #   have been registered via 'add_remote'
        # @option opts [Boolean] deep if true fetch all nested cards, too
        # @option opts [Boolean] items_only if true fetch all nested cards but
        #   not the card itself
        def pull name, opts={}
          MetaData.update do |meta_data|
            url = opts[:remote] ? meta_data.url(opts.delete(:remote)) : nil
            fetch_card_data(name, url, opts).each do |card_data|
              saved_data = meta_data.add_card card_data
              write_card_content saved_data[:key], card_data[:content]
            end
          end
        end

        # Save an url as remote deck to make it available for the pull method
        def add_remote name, url
          MetaData.update do |meta_data|
            meta_data.remotes[name] = url
          end
        end

        private

        def card_data_for_merge all
          MetaData.cards.map do |data|
            next unless all || needs_update?(data)
            key = data[:key] || data[:name].to_name.key
            hash = {
              'name' => data[:name],
              'type' => data[:type],
              'content' => File.read(content_path(key))
            }
            hash['codename'] = data[:codename] if data[:codename]
            hash
          end.compact
        end

        def write_card_content key, content
          FileUtils.mkpath CARD_CONTENT_DIR unless Dir.exist? CARD_CONTENT_DIR
          File.write content_path(key), content
        end

        def needs_update? data
          !data[:pushed] ||
            data[:pushed] < File.mtime(content_path(data[:name]))
        end

        # Returns an array of hashes with card attributes
        def fetch_card_data name, url, opts
          view, result_key =
            if opts[:items_only]
              ['export_items', nil]
            elsif opts[:deep]
              ['export', nil]
            else
              [nil, :card]
            end

          card_data =
            if url
              fetch_remote_data name, view, url
            else
              fetch_local_data name, view
            end
          result_key ? [card_data[result_key]] : card_data
        end

        def fetch_remote_data name, view, url
          json_url = "#{url}/#{name}.json"
          json_url += "?view=#{view}" if view
          json = open(json_url).read
          JSON.parse(json).deep_symbolize_keys
        end

        def fetch_local_data name, view
          Card[name].format(format: :json).render(view || :content)
        end

        def content_path card_key
          File.join CARD_CONTENT_DIR, card_key
        end
      end

      # Handles the card attributes and remotes for the import
      class MetaData
        DEFAULT_PATH = Card::Migration.data_path('cards.yml').freeze

        class << self
          def update
            data = MetaData.new
            yield(data)
            data.write
          end

          def cards
            MetaData.new.cards
          end
        end

        def initialize path=nil
          @path = path || DEFAULT_PATH
          ensure_path
          @data = read
        end

        def cards
          @data[:cards]
        end

        def remotes
          @data[:remotes]
        end

        def url remote
          @data[:remotes][remote.to_sym] ||
            raise("unknown remote: #{remote}")
        end

        def add_card_attribute name, attr_key, attr_value
          card = find_card name
          return unless card
          card[attr_key] = attr_value
          card
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
          card_data
        end

        def read
          return { cards: [], remotes: {} } unless File.exist? @path
          YAML.load_file(@path).deep_symbolize_keys
        end

        def write
          File.write @path, @data.to_yaml
        end

        private

        def find_card name
          key = name.to_name.key
          index =
            cards.find_index do |attr|
              attr[:key] == key
            end
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
