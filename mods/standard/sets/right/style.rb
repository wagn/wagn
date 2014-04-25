
require 'sass'

def self.delete_style_files
  Auth.as_bot do
    Card.search( :right=>{:codename=>'style'}, :return=>'id' ).each do |style_file_id|
      Card.delete_tmp_files style_file_id
    end
  end
end

#FIXME - the following could be unified with type/file.rb considerably

# note that this was formerly accomplished as a separate File card (eg *all+*style+file).  The issue was that the permanent
# file regularly caused problems with non-root wagns, and requiring users to re-save the *all+*style rule upon updates
# to CSS, SCSS, and Skin cards was not popular.

def style_file
  Wagn.paths['files'].existent.first + "/tmp/#{ id }/#{ style_fingerprint }.css"
end

def style_path
  "#{ Wagn.config.files_web_path }/#{ name.to_name.url_key }-#{ style_fingerprint }.css"
end

def style_fingerprint
  item_cards.map do |item|
    item.respond_to?( :style_fingerprint ) ? item.style_fingerprint : item.current_revision_id.to_s
  end.join '-'
end


format do
  # FIXME - this should be a read event (when we have read events)
  view :not_found do |args|
    if card.real?
      compressed_css = card.compress_stylesheets
      filename = card.style_file 
      FileUtils.mkdir_p File.dirname(filename)  
      File.open filename, 'w' do |f|
        f.write compressed_css
      end
      self.error_status = 302
      wagn_path card.style_path
    else
      _final_not_found args
    end
  end
  
end


format :file do
  view :core do |args|
    if params[:explicit_file] and r = controller.response
      r.headers["Expires"] = 1.year.from_now.httpdate
    end
    
    [ card.style_file, { :filename=>"#{card.cardname.url_key}.css",
        :x_sendfile=>true, :type=>'text/css', :disposition=>'inline' } ]
  end
end


def compress_stylesheets
  Auth.as_bot do
    format = Card::CssFormat.new self
    Sass.compile format._render_core, :style=>:compressed
  end
rescue Exception=>e
  raise Card::Oops, "Stylesheet Error:\n#{ e.message }"
end

