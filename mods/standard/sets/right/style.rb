# -*- encoding : utf-8 -*-

event :save_stylesheet, :after=>:store, :on=>:save do
  compressed_css = compress_stylesheets

  tmpdir = Rails.root.join 'tmp'
  Tempfile.open [name, '.css'], tmpdir do |f|    
    f.write compressed_css
    c = Card.fetch "#{name}+file", :new=>{ :type=>'File' }
    c.attach = f
    c.save!
  end
end


def compress_stylesheets
  format = Card::CssFormat.new self
  Sass.compile format.render_core, :style=>:compressed
rescue Exception=>e
  raise Wagn::Oops, "Stylesheet Error:\n#{ e.message }"
end