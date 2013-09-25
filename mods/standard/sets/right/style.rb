# -*- encoding : utf-8 -*-

def self.delete_style_files
  Account.as_bot do
    Card.search( :right=>{:codename=>'style'}, :return=>'id' ).each do |style_file_id|
      Card.delete_tmp_files style_file_id
    end
  end
end

#FIXME - the following could be unified with type/file.rb considerably

def style_file
  Wagn::Conf[:attachment_storage_dir] + "/tmp/#{id}/#{current_revision_id}.css"
end

def style_path
  Wagn::Conf[:attachment_web_dir] + "/#{name.to_name.url_key}-#{current_revision_id}.css"
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
      card.style_path
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
  Account.as_bot do
    format = Card::CssFormat.new self
    Sass.compile format._render_core, :style=>:compressed
  end
rescue Exception=>e
  raise Wagn::Oops, "Stylesheet Error:\n#{ e.message }"
end

