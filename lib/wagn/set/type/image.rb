module Wagn::Set::Type::Image
  def legacy_source(tag, size=nil)
    source = tag.match(/src=\"([^\"]+)/)[1]
    size ? resize_legacy_image_content(source, size) : source
  end
  
  def legacy_content
    (rr = _render_raw) && rr =~ /^\s*\</ && rr
  end
  
  def resize_legacy_image_content(content, size)
    return content if !size || size.blank?
    size = (size.to_s == "full" ? "" : "_#{size}")
    content.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
  end

end
