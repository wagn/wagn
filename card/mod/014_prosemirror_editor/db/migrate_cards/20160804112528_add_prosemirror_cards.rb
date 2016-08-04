# -*- encoding : utf-8 -*-

class AddProsemirrorCards < Card::Migration
  def up
    unless Card[:prose_mirror]
      Card.create! name: '*ProseMirror', type: PlainTextID,
                   codename: 'prose_mirror',
                   content: <<-JSON.strip_heredoc
                              {
                                "menuBar": true,
                                "tooltipMenu": false
                              }
                            JSON
    end
    create_or_update(
      name: '*ProseMirror+*self+*help',
      content: "Configure [[http://prosemirror.net|ProseMirror]], "\
               "Wagn's default [[http://en.wikipedia.org/wiki/Wysiwyg|wysiwyg]] "\
               "editor. [[http://wagn.org/ProseMirror|more]]"
    )
  end
end
