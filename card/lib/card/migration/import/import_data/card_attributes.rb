class Card
  class Migration
    class Import
      class ImportData
       # handles card attributes for import
       module CardAttributes
         def card_attributes data
           card_attr = ::Set.new [:name, :type, :codename, :file, :image]
           data.select { |k, v| v && card_attr.include?(k) }
         end

         def update_card_attributes card_data
           card_entry = find_card card_data[:name]
           if card_entry
             card_entry.replace card_data
           else
             cards << card_data
           end
         end

         def update_attribute name, attr_key, attr_value
           card = find_card_attributes name
           return unless card
           card[attr_key] = attr_value
           card
         end

         def write_attibutes
           File.write @path, @data.to_yaml
         end

         def read_attributes
           ensure_path
           return { cards: [], remotes: {} } unless File.exist? @path
           YAML.load_file(@path).deep_symbolize_keys
         end

         def find_card_attributes name
           key = name.to_name.key
           index = cards.find_index { |attr| attr[:key] == key } ||
             cards.find_index { |attr| attr[:name] == name }
           return unless index
           cards[index]
         end

         private

         def ensure_path
           dir = File.dirname(@path)
           FileUtils.mkpath dir unless Dir.exist? dir
         end
       end
      end
    end
  end
end
