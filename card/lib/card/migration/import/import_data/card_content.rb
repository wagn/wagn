class Card
  class Migration
    class Import
      class ImportData
        # handles card content for import
        module CardContent
          def card_content data
            File.read(content_path(data))
          end

          def content_changed? data
            Time.parse(data[:merged]) < File.mtime(content_path(data))
          end

          private

          def write_card_content data, content
            FileUtils.mkpath @card_content_dir unless Dir.exist? @card_content_dir
            File.write content_path(data), content.to_s
          end

          def content_path data
            filename = data[:key] || data[:name].to_name.key
            File.join @card_content_dir, filename
          end
        end
      end
    end
  end
end

