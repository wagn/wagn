class SetStarTinyMce < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "*tinyMCE", :type=>"PlainText"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
width: '100%',
auto_resize : true,
relative_urls: false,
theme : "advanced",
theme_advanced_buttons1 : "formatselect,bold,italic,separator,"
+ "blockquote,bullist,numlist,hr,separator,"
+ "code",                         
theme_advanced_buttons2 : "",                         
theme_advanced_buttons3 : "",                         
theme_advanced_path : false,                         
theme_advanced_toolbar_location : "top",  
theme_advanced_toolbar_align : "left", 
theme_advanced_resizing : true,
theme_advanced_resize_horizontal : false,                      
theme_advanced_statusbar_location : "bottom",
theme_advanced_blockformats : "p,h1,h2",
content_css : '/stylesheets/defaults.css,/card/view/*css?layout=none',
extended_valid_elements : "a[name|href|target|title|onclick],"
+ "img[class|src|border=0|alt|title|hspace|vspace|width|height|"
+ "align|onmouseover|onmouseout|name],hr[class|width|size|noshade],"
+ "font[face|size|color|style],span[class|align|style]"          

CONTENT
        card.permit('edit',Role[:admin])
        card.permit('delete',Role[:admin])
        card.save!
      end
    end
  end

  def self.down
  end
end
