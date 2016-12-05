class Card
  class Migration
    class Import
      class ImportData
        # handles card content for import
        module CardContent
          CARD_CONTENT_DIR = Card::Migration.data_path("cards").freeze

          def card_content data
            File.read(content_path(data))
          end

          def content_changed? data
            Time.parse(data[:merged]) < File.mtime(content_path(data))
          end

          private

          def write_card_content data, content
            FileUtils.mkpath CARD_CONTENT_DIR unless Dir.exist? CARD_CONTENT_DIR
            File.write content_path(data), content.to_s
          end

          def content_path data
            filename = data[:key] || data[:name].to_name.key
            File.join CARD_CONTENT_DIR, filename
          end
        end
      end
    end
  end
end

