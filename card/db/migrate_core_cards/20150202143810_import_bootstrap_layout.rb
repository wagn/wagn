# -*- encoding : utf-8 -*-

class ImportBootstrapLayout < Card::CoreMigration
  def up
    import_json "bootstrap_layout.json"
  end
end
