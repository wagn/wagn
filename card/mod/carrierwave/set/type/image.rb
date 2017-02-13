attachment :image, uploader: CarrierWave::ImageCardUploader

include File::SelectedAction

format do
  include File::Format

  view :closed_content do
    _render_core size: :icon
  end

  view :source, cache: :never do
    determine_image_size
    source_url
  end

  def source_url
    return card.raw_content if card.web?
    internal_url selected_version.url
  end

  def selected_version
    if voo.size == :original
      card.image
    else
      card.image.versions[voo.size.to_sym]
    end
  end

  def default_core_args _args={}
    determine_image_size
  end

  def determine_image_size
    voo.size =
      case
      when @mode == :closed   then :icon
      when voo.size           then voo.size.to_sym
      when main?              then :large
      else                         :medium
      end
    voo.size = :original if voo.size == :full
  end
end

format :html do
  include File::HtmlFormat

  view :core, cache: :never do
    handle_source do |source|
      if source == "missing"
        "<!-- image missing #{@card.name} -->"
      else
        image_tag source
      end
    end
  end

  def preview
    return if card.new_card? && !card.preliminary_upload?
    voo.size = :medium
    wrap_with :div, class: "attachment-preview",
                    id: "#{card.attachment.filename}-preview" do
      _render_core
    end
  end

  def show_action_content_toggle? _action, _view_type
    true
  end

  view :content_changes do |args|
    action = args[:action]
    voo.size = args[:diff_type] == :summary ? :icon : :medium
    [old_image(action, args), new_image(action)].compact.join
  end

  def old_image action, args
    return if args[:hide_diff] || !action
    return unless (last_change = card.last_change_on(:db_content, before: action))
    card.with_selected_action_id last_change.card_action_id do
      Card::Content::Diff.render_deleted_chunk _render_core
    end
  end

  def new_image action
    card.with_selected_action_id action.id do
      Card::Content::Diff.render_added_chunk _render_core
    end
  end
end

format do
  view :inline do
    _render_core
  end
end

format :email_html do
  view :inline do
    determine_image_size
    url_generator = voo.closest_live_option(:inline_attachment_url)
    path = selected_version.path
    return _render_source unless url_generator && ::File.exist?(path)
    image_tag url_generator.call(path)
  end
end

format :css do
  view :core do
    render_source
  end

  view :content do  # why is this necessary?
    render_core
  end
end

format :file do
  include File::FileFormat

  def image_style
    ["", "full"].member?(params[:size].to_s) ? :original : params[:size].to_sym
  end

  def selected_file_version
    style = voo.size = image_style.to_sym
    if style && style != :original
      card.attachment.versions[style]
    else
      card.attachment
    end
  end
end
