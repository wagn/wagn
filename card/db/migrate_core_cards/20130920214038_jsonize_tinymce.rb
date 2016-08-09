# -*- encoding : utf-8 -*-

class JsonizeTinymce < Card::CoreMigration
  def up
    card = Card[:tiny_mce]
    cleaned_rows = card.content.strip.split(/\s*\,\s+/).map do |row|
      key, val = row.split(/\s*\:\s*/)
      val.gsub!(/\"\s*\+\s*\"/, "")
      val.gsub! "'", '"‚'
      %("#{key}":#{val})
    end
    card.content = %({\n#{cleaned_rows.join ",\n"}\n})
    card.save!
  end
end
