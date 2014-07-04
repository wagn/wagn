
include File

format do
  
  include File::Format

  view :closed_content do |args|
    _render_core :size=>:icon
  end

  view :source do |args|
    style = case
      when @mode==:closed ;  :icon
      when args[:size]    ;  args[:size]
      when main?          ;  :large
      else                ;  :medium
      end
    style = :original if style.to_sym == :full
    card.attach.url style
  end

end

format :html do
  include File::HtmlFormat

  view :core do |args|
    handle_source args do |source|
      source == 'missing' ? "<!-- image missing #{@card.name} -->" : image_tag(source)
    end
  end


  view :diff do |args|
    out = ''
    if @show_diff and @previous_revision
      card.selected_revision_id=@previous_revision.id
      out << _render_core
    end
    card.selected_revision_id=@revision.id
    out << _render_core
    out
  end

end

format :css do
  view :core do |args|
    render_source
  end
  
  view :content do |args|
    render_core
  end
end

format :file do
  include File::FileFormat

  view :style do |args|  #should this be in model?
    ['', 'full'].member?( args[:style].to_s ) ? :original : args[:style]
  end
    
end

