# -*- encoding : utf-8 -*-

class AddFullWidthLayoutCard < Card::Migration::Core
  LAYOUT =
    <<-HTML.strip_heredoc
      <!DOCTYPE HTML>
      <html>
        <head>
          {{*head|core}}
        </head>
        <body class="left-sidebar thin-sidebar fluid">
          <header>{{*header|core}}</header>
          <article>{{_main|open}}</article>
          <aside>{{*sidebar|content}}</aside>
          <footer>{{*footer|core}}</footer>
        </body>
      </html>
    HTML

  def up
    ensure_card "Full Width Layout", type_id: Card::LayoutTypeID, content: LAYOUT
  end
end
