class SetStarCss < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*css", :type=>"HTML"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
/* body text */
body {
  color: #444444;
}

/* page - background image and color */
body#wagn {
  background: url(/images/body-bg.png) repeat-x #CCCCCC;
}

/* main card and sidebar widths */
#primary {
  width:67%;
}
#secondary {
  width:28%;
}

/* top bar background color; text colors */
#menu {
  background: #335533;
}
#menu a {
  color: #EEEEEE;
}

/* header text */
h1, h2 {
  color: #664444;
}
h1.page-header, 
h2.page-header {
  color: #222299; 
}


/* card headers etc */
.card-header {
  background: #C0D9C0;
}
.card-header,
.card-header a {
  font-weight: normal;
  color: #333333; 
}

/* misc */

.card-footer, 
.revision-navigation, 
.current,
#credit {
  background: #DDDDDD;
}

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
