# -*- encoding : utf-8 -*-

class ResponsiveSidebar < Card::Migration::Core
  def up
    if (layout = Card.fetch "Default Layout") &&
       layout.updater.id == Card::WagnBotID
      new_content = layout.content.gsub "<body>", '<body class="right-sidebar">'
      layout.update_attributes! content: new_content
    end
  end
end
