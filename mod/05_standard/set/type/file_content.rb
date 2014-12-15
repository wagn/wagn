
  
view :raw do |args|  
  path = card.content
  path.sub!("WagnGem:",Wagn.gem_root+"/") if path.start_with?("WagnGem:")
  full_path = ::File.expand_path(path)
  if not full_path.start_with?( Wagn.gem_root, Rails.root.to_s+"/mod") 
    return "Insecure path. Path should be within Wagn Gem or wagn mod."
  end
  if not ::File.file?(full_path)
    return "Non existing file path." 
  end
  ::File.read full_path
end

view :core do |args|
  _render_raw 
end

format :html do
  view :editor, :mod=>PlainText::HtmlFormat
  view :core do |args|
    CGI.escapeHTML _render_raw 
  end
end
