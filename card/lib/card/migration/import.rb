require "import_data"

class Card
  class Migration
    # Imports card data from a local or remote deck
    #
    # The cards' content for the import is stored for every card in a separate
    # file, other attributes like name or type are stored for all cards together
    # in a yml file.
    #
    # To update a card's content you only have to change the card's content
    # file. The merge method will recognize that the file was changed
    # since the last merge and merge it into the cards table
    # To update other attributes change them in the yml file and either remove
    # the 'merged' value or touch the corresponding content file
    class Import
      OUTPUT_FILE = Card::Migration.data_path "unmerged"
      class << self
        # Merge the import data into the cards table
        # If 'all' is true all import data is merged.
        # Otherwise only the data that was changed or added since the last merge
        def merge all=false
          merge_data = all ? ImportData.all_cards : ImportData.changed_cards
          puts("nothing to merge") && return if merge_data.empty?

          Card::Mailer.perform_deliveries = false
          Card::Auth.as_bot do
            Card.merge_list merge_data, output_file: OUTPUT_FILE
          end
          update_time = Time.zone.now.to_s
          ImportData.update do |import_data|
            merge_data.each do |card_data|
              import_data.merged card_data, update_time
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
          ImportData.update do |import_data|
            url = opts[:remote] ? import_data.url(opts.delete(:remote)) : nil
            fetch_card_data(name, url, opts).each do |card_data|
              import_data.add_card card_data
            end
          end
        end

        # Add a card with the given attributes to the import data
        def add_card attr
          ImportData.update do |data|
            data.add_card attr
          end
        end

        # Save an url as remote deck to make it available for the pull method
        def add_remote name, url
          ImportData.update do |data|
            data.add_remote name, url
          end
        end

        private

        # Returns an array of hashes with card attributes
        def fetch_card_data name, url, opts
          view, result_key =
            if opts[:items_only]
              ["export_items", nil]
            elsif opts[:deep]
              ["export", nil]
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
          Card::Auth.as_bot do
            Card[name].format(format: :json).render(view || :content)
          end
        end
      end
    end
  end
end
