# -*- encoding : utf-8 -*-

class AddTinymceCards < Card::Migration
  def up
    unless Card[:tiny_mce]
      Card.create!(
        name: '*TinyMCE', type: PlainTextID,
        codename: 'tiny_mce',
        content: <<-JSON.strip_heredoc
          {
            "width":"100%",
            "auto_resize":true,
            "relative_urls":false,
            "theme":"advanced",
            "theme_advanced_buttons1":"formatselect,bold,italic,separator,blockquote,bullist,numlist,hr,separator,code,removeformat",
            "theme_advanced_buttons2":"",
            "theme_advanced_buttons3":"",
            "theme_advanced_path":false,
            "theme_advanced_toolbar_location":"top",
            "theme_advanced_toolbar_align":"left",
            "theme_advanced_resizing":true,
            "theme_advanced_resize_horizontal":false,
            "theme_advanced_statusbar_location":"bottom",
            "theme_advanced_blockformats":"p,h1,h2,pre",
            "extended_valid_elements":"a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]"
          }
        JSON
      )
    end
    create_or_update(
      name: '*TinyMCE+*self+*help',
      content: "Configure [[http://tinymce.com|TinyMCE]], Wagn's default [[http://en.wikipedia.org/wiki/Wysiwyg|wysiwyg]] editor. [[http://wagn.org/TinyMCE|more]]"
    )
  end
end
