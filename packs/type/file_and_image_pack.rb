
class Wagn::Renderer

  define_view(:naked, :type=>'image') do |args|
    image_tag card.attach.url args[:size] || :medium
  end
  alias_view(:naked, {:type=>'image'}, :raw)

  define_view(:naked, :type=>'file') do |args|
    "<a href=\"#{card.attach.url}\">#{card.name}</a>"
  end
  alias_view(:naked, {:type=>'file'}, :raw)

end

class Wagn::Renderer::Html
  define_view(:editor, :type=>'file') do |args|
    Rails.logger.debug "editor for file #{card.inspect}"
    %{<div class="attachment-preview", :id="#{card.attach_file_name}-preview"> #{
       #!card.new_card? && card.attach ? _render_naked(args) : ''
       _render_naked(args)
    } </div>

    <div> #{
      #warn "file form for #{card}, [#{form.object_name}]"
      form.file_field :attach
    }
    </div>}
  end

  alias_view :editor, {:type=>:file}, {:type=>:image}
end
