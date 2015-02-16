
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


  view :content_changes do |args|
    out = ''
    size = args[:diff_type]==:summary ? :icon : :medium
    if !args[:hide_diff] and args[:action] and last_change = card.last_change_on(:db_content,:before=>args[:action])
      card.selected_action_id=last_change.card_action_id
      out << Card::Diff.render_added_chunk(_render_core(:size=>size))
    end
    card.selected_action_id=args[:action].id
    out <<  Card::Diff.render_deleted_chunk(_render_core(:size=>size))
    out
  end

end

format :css do
  view :core do |args|
    render_source
  end
  
  view :content do |args|  #why is this necessary?
    render_core
  end
end

format :file do
  include File::FileFormat

  view :style do |args|  #should this be in model?
    ['', 'full'].member?( args[:style].to_s ) ? :original : args[:style]
  end
    
end

