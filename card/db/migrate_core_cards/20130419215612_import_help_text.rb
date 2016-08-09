# -*- encoding : utf-8 -*-

class ImportHelpText < Card::CoreMigration
  def up
    dir = data_path "1.11_help_text.json"
    data = JSON.parse(File.read dir)
    data.each do |atom|
      c = atom["card"]
      Card.merge c["name"], { type: c["type"], content: atom["views"][0]["parts"] }, pristine: true
    end
  end
end
