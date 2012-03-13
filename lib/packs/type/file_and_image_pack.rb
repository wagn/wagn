class Wagn::Renderer
  
  define_view(:core, :type=>'image') do |args|
    (source = _render_source( args )) ? image_tag( source ) : ''
  end

  define_view(:core, :type=>'file') do |args|
    (source = _render_source) ?  "<a href=\"#{source}\">Download #{card.name}</a>" : ''
  end

  define_view(:closed_content, :type=>'image') do |args|
    _render_core :size=>:icon
  end
  
  define_view(:source, :type=>'image') do |args|
    attach_url( @mode==:closed ? :icon : ( args[:size] || :medium ) )
  end

  define_view(:source, :type=>'file') do |args|
    attach_url
  end
  
  private

  def attach_url(style=nil)
    return nil if card.content.blank?
    style = :original if style && style.to_sym == :full 
    card.attach.url style
  rescue
    nil #not wild about this, but attach raises errors when the content is not proper attachment data
  end
  
end




class Wagn::Renderer::Html
  define_view(:editor, :type=>'file') do |args|
    Rails.logger.debug "editor for file #{card.inspect}"
    out = '<div class="choose-file">'
    if !card.new_card?
      out << %{<div class="attachment-preview", :id="#{card.attach_file_name}-preview"> #{_render_core(args)} </div> }
    end
    out << %{
      <div>#{form.file_field :attach, :class=>'file-upload slotter'}</div>
    </div>
    <div class="chosen-file" style="display:none">
      <div><label>File chosen:</label> <span class="chosen-filename"></span></div>
      <div><a class="cancel-upload">Unchoose</a></div>
    </div>
      }
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
