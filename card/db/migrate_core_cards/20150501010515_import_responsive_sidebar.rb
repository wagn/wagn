# -*- encoding : utf-8 -*-

class ImportResponsiveSidebar < Card::CoreMigration
  def up
    import_json "responsive_sidebar.json"
    
  end
end
