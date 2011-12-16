
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

  define_view(:changes, :type=>'image') do |args| #ENGLISH
    @revision_number = (params[:rev] || (card.revisions.count - card.drafts.length)).to_i
    @revision = card.revisions[@revision_number - 1]
    @show_diff = (params[:mode] != 'false')
    @previous_revision= card.previous_revision(@revision)
    
    wrap(:changes, args) do
    %{#{header unless params['no_changes_header']}
    <div class="revision-navigation">#{ revision_menu }</div>

    <div class="revision-header">
      <span class="revision-title">#{ @revision.title }</span>
      posted by #{ link_to_page @revision.author.card.name }
    on #{ format_date(@revision.created_at) } #{
    if !card.drafts.empty?
      %{<p class="autosave-alert">
        This card has an #{ autosave_revision }
      </p>}
    end}#{
    if @show_diff and @previous_revision  #ENGLISH
      %{<p class="revision-diff-header">
        <small>
          Showing changes from revision ##{ @revision_number - 1 }:
          <ins class="diffins">Added</ins> | <del class="diffmod">Removed</del>
        </small>
      </p>}
    end}

    </div>


    <div class="revision">#{
    if @show_diff and @previous_revision
      card.selected_rev_id=@previous_revision.id
      _render_core
    end
    }
   #{ card.selected_rev_id=@revision.id
    _render_core
   } </div>

    <div class="revision-navigation card-footer">
    #{ revision_menu }
    </div>}
    end
  end
end
