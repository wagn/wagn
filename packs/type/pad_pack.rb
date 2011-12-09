class Wagn::Renderer::Html

  define_view(:current) do |args| _render_raw end
  define_view(:current_naked) do |args| _render_naked end

  define_view(:current, :fallback=>:raw, :type=>'Pad') do |args|
    Rails.logger.debug "current_pad view #{card}, #{card.inspect}"
    card.include_set_modules
    card.get_pad_content
  end
  
  define_view(:current_naked, :fallback=>:naked, :type=>'Pad') do |args|
    process_content _render_current
  end

  define_view(:open_content, :type=>'Pad') do |args|
    card.post_render(_render_current_naked { yield })
  end

  # edit views
  define_view(:edit, :type=>'Pad') do |args|
    @state=:edit
    self._render_editor
  end

  define_view(:editor, :type=>'Pad') do |args|
    eid, raw_id = context, context+'-raw-content'
    epad_opts = card.pad_options
    %{#{form.hidden_field( :content, :id=>"#{eid}-hidden-content" )}#{
      text_area_tag :content_to_replace, '...', :style=>'display:none', :id=>"#{eid}-epad"
      }<iframe id="epframe-#{eid}" width="100%" height="500" src="#{
      epad_opts[:url]}#{card.key
      }?showControls=#{epad_opts[:showControls]
      }&showChat=#{epad_opts[:showChat]
      }&showLineNumbers=#{epad_opts[:showLineNumbers]
      }&useMonospaceFont=#{epad_opts[:useMonospaceFont]
      }&userName=#{User.current_user.card.name
      }&noColors=#{epad_opts[:noColors]}"></iframe>
    }
  end

end
