# -*- encoding : utf-8 -*-

event :save_stylesheet, :after=>:store, :on=>:save do
  format = Card::CssFormat.new self
  compressed_css = Sass.compile format.render_core, :style=>:compressed  
  tmpdir = Rails.root.join 'tmp'

  Tempfile.open [name, '.css'], tmpdir do |f|    
    f.write compressed_css
    c = Card.fetch "#{name}+file", :new=>{ :type=>'File' }
    c.attach = f
    c.save!
  end

end


