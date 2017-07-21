class Card
  class Migration
    class Import
      # executes the card import
      class Merger
        def initialize data_path, opts={}
          @output_path = File.join data_path, "unmerged"
          load_data opts
        end

        def merge
          puts("nothing to merge") && return if @data.empty?

          Card::Mailer.perform_deliveries = false
          Card::Auth.as_bot do
            Card.merge_list @data, output_file: @output_path
          end

          update_import_data
        end

        private

        def load_data opts
          @data =
            if opts[:all]
              ImportData.all_cards
            elsif opts[:only]
              ImportData.select_cards opts[:only]
            else
              ImportData.changed_cards
            end
        end

        def update_import_data
          update_time = Time.zone.now.to_s
          ImportData.update do |import_data|
            @data.each do |card_data|
              import_data.merged card_data, update_time
            end
          end
        end
      end
    end
  end
end
