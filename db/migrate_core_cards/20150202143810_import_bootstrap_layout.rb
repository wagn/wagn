# -*- encoding : utf-8 -*-

class ImportBootstrapLayout < Wagn::CoreMigration
  def up
    import_json "bootstrap_layout.json"
    Card['*all+*layout'].update_attributes :content=>'[[Bootstrap Layout]]'
    Card['*all+*style'].update_attributes :content=>'[[bootstrap skin]]'
  end
end
