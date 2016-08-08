attachment :image, uploader: ImageUploader

include File::SelectedAction

format do
  include File::Format

  view :closed_content do |_args|
    _render_core size: :icon
  end

  view :source do |args|
    style =
      case
      when @mode == :closed then :icon
      when args[:size]    then args[:size].to_sym
      when main?          then :large
      else :medium
      end
    style = :original if style.to_sym == :full
    if style == :original
      card.image.url
    else
      card.image.versions[style].url
    end
  end
end

format :html do
  include File::HtmlFormat

  view :core do |args|
    handle_source args do |source|
      if source == "missing"
        "<!-- image missing #{@card.name} -->"
      else
        image_tag(source)
      end
    end
  end

  def preview args
    if !card.new_card? || card.preliminary_upload?
      content_tag :div, _render_core(args.merge(size: :medium)).html_safe,
                  class: "attachment-preview",
                  id: "#{card.attachment.filename}-preview"
    end
  end

  view :content_changes do |args|
    out = ""
    size = args[:diff_type] == :summary ? :icon : :medium
    if !args[:hide_diff] && args[:action] &&
       (last_change = card.last_change_on(:db_content, before: args[:action]))
      card.selected_action_id = last_change.card_action_id
      out << Card::Diff.render_deleted_chunk(_render_core(size: size))
    end
    card.selected_action_id = args[:action].id
    out << Card::Diff.render_added_chunk(_render_core(size: size))
    out
  end
end

format :css do
  view :core do |_args|
    render_source
  end

  view :content do |_args|  # why is this necessary?
    render_core
  end
end

format :file do
  include File::FileFormat

  view :style do |args|  # should this be in model?
    ["", "full"].member?(args[:style].to_s) ? :original : args[:style]
  end

  def selected_file_version
    style = _render_style(style: params[:size]).to_sym
    if style && style != :original
      card.attachment.versions[style]
    else
      card.attachment
    end
  end
end
