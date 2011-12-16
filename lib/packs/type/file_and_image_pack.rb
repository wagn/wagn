
class Wagn::Renderer
  
  define_view(:core, :type=>'image') do |args|
    (rr = _render_raw) =~ /^\s*<img / ? resize_legacy_image_content( rr, args[:size] ) :
      image_tag(card.attach.url args[:size] || :medium)
  end

  define_view(:core, :type=>'file') do |args|
    (rr = _render_raw) =~ /^\s*<a / ? rr :
      "<a href=\"#{card.attach.url}\">Download #{card.name}</a>"
  end

  define_view(:closed_content, :type=>'image') do |args|
    _render_core(:size=>:icon)
  end

  private
  
  def resize_legacy_image_content(content, size)
    return content if !size || size.blank?
    size = (size.to_s == "full" ? "" : "_#{size}")
    content.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
  end
end




class Wagn::Renderer::Html
  define_view(:editor, :type=>'file') do |args|
    Rails.logger.debug "editor for file #{card.inspect}"
    out = ''
    if !card.new_card?
      out << %{<div class="attachment-preview", :id="#{card.attach_file_name}-preview"> #{_render_core(args)} </div> }
    end
    out << %{<div>#{form.file_field :attach, :class=>'file-upload'}</div>}
    out
  end

  alias_view :editor, {:type=>:file}, {:type=>:image}

  define_view(:diff, :type=>'image') do |args|
    out = ''
    if @show_diff and @previous_revision
      card.selected_rev_id=@previous_revision.id
      out << _render_core
    end
    card.selected_rev_id=@revision.id
    out << _render_core
    out
  end  
end
