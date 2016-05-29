# Imports card data
class Card
  class Migration
    class Import
      class << self
        CARD_CONTENT_DIR = Card::Migration.data_path('cards').freeze
        CARD_META_DATA_PATH = Card::Migration.data_path('cards.json').freeze

        def merge all=false
          merge_data = card_data_for_merge all
          if merge_data.empty?
            puts 'nothing to push'
            return
          end
          output_file = Card::Migration.data_path "unmerged"
          Card::Mailer.perform_deliveries = false
          Card::Auth.as_bot do
            Card.merge_list merge_data, output_file: output_file
          end
          update_time = Time.now
          update_meta_data do
            merge_data.each do |card_attr|
              update_card_attribute card_attr['name'], :pushed, update_time
            end
          end
        end

        # @param [Hash] opts option hash
        # @option opts [String] remote
        # @option opts [String] deep
        # @option opts [String] items_only
        def pull name, opts={}
          card_data = fetch_card_data name, opts

          update_meta_data do
            card_data.each do |data|
              add_card_to_import_data data
            end
          end
        end

        def add_remote name, url
          update_meta_data do
            meta_data[:remotes] ||= {}
            meta_data[:remotes][name] = url
          end
        end

        private

        def card_data_for_merge all
          meta_data[:cards].map do |data|
            next unless all || needs_update?(data)
            hash = {
              'name' => data[:name],
              'type' => data[:type],
              'content' => File.read(content_path(data[:name]))
            }
            hash['codename'] = data[:codename] if data[:codename]
            hash
          end.compact
        end

        def url remote
          meta_data[:remotes] && meta_data[:remotes][remote.to_sym] ||
            fail("unknown remote: #{remote}")
        end

        def needs_update? data
          binding.pry
          !data[:pushed] || data[:pushed] < File.mtime(content_path(data[:name]))
        end

        def update_meta_data
          ensure_path
          meta_data
          yield
          write_meta_data
        end

        def fetch_card_data name, opts
          view, result_key =
            if opts[:items_only]
              ['export_items', nil]
            elsif opts[:deep]
              ['export', nil]
            else
              [nil, :card]
            end

          card_data =
            if opts[:remote]
              json = fetch_remote_json(name, view, opts[:remote])
              JSON.parse(json).deep_symbolize_keys
            else
              fetch_local_data(name, view)
            end
          result_key ? [card_data[result_key]] : card_data
        end

        # @return JSON string
        def fetch_remote_json name, view, remote
          json_url = "#{url(remote)}/#{name}.json"
          json_url += "?view=#{view}" if view
          open(json_url).read
        end

        # @return hash or array depending on the view
        def fetch_local_data name, view
          Card[name].format(format: :json).render(view || :content)
        end

        def add_card_to_import_data attr
          add_card_attributes attr
          File.write content_path(attr[:name]), attr[:content]
        end

        def content_path cardname
          File.join CARD_CONTENT_DIR, cardname.to_name.key
        end

        def update_card_attribute name, attr_key, attr_value
          card_key = name.to_name.key
          index =
            meta_data[:cards].find_index do |attr|
              attr[:key] == card_key
            end
          return unless index
          meta_data[:cards][index][attr_key] = attr_value
        end

        def add_card_attributes data
          card_attr = {}
          [:name, :type, :codename].each do |key|
            card_attr[key] = data[key]
          end
          card_attr[:key] = data[:name].to_name.key
          index =
            meta_data[:cards].find_index do |attr|
              attr[:key] == data[:key]
            end
          if index
            meta_data[:cards][index] = card_attr
          else
            meta_data[:cards] << card_attr
          end
        end

        def meta_data
          @meta_data ||= fetch_meta_data
        end

        def fetch_meta_data
          return { cards: [], remotes: {} } unless File.exists? CARD_META_DATA_PATH
          JSON.parse(File.read(CARD_META_DATA_PATH)).deep_symbolize_keys
        end

        def write_meta_data
          ensure_path
          File.write CARD_META_DATA_PATH, JSON.pretty_generate(meta_data)
        end

        def ensure_path
          FileUtils.mkpath CARD_CONTENT_DIR unless Dir.exist? CARD_CONTENT_DIR
        end
      end
    end
  end
end
