attachment :file, uploader: CarrierWave::FileCardUploader

module SelectedAction
  def select_action_by_params params
    # skip action table lookups for current revision
    rev_id = params[:rev_id]
    super unless rev_id && rev_id == last_content_action_id
  end

  def last_content_action_id
    return super if temporary_storage_type_change?
    # find action id from content (saves lookups)
    db_content.to_s.split(%r{[/\.]})[-2]
  end
end
include SelectedAction

format do
  view :source do
    source_url
  end

  def source_url
    internal_url card.attachment.url
  end

  view :core do
    handle_source do |source|
      card_url source
    end
  end

  def handle_source
    source = source_url
    source ? yield(source) : ""
  rescue
    "File Error"
  end
end

format :file do
  # returns send_file args.  not in love with this...
  view :core, cache: :never do |_args|
    # this means we only support known formats.  dislike.
    attachment_format = card.attachment_format(params[:format])
    return _render_not_found unless attachment_format
    return card.format(:html).render_core(args) if card.remote_storage?
    set_response_headers
    args_for_send_file
  end

  def args_for_send_file
    file = selected_file_version
    [
      file.path,
      {
        type: file.content_type,
        filename:  "#{card.cardname.safe_key}#{file.extension}",
        x_sendfile: true,
        disposition: (params[:format] == "file" ? "attachment" : "inline")
      }
    ]
  end

  def set_response_headers
    return unless params[:explicit_file] && (r = controller.response)
    r.headers["Expires"] = 1.year.from_now.httpdate
    # currently using default "private", because proxy servers could block
    # needed permission checks
    # r.headers["Cache-Control"] = "public"
  end

  def selected_file_version
    card.attachment
  end
end

format :html do
  view :core do |args|
    handle_source do |source|
      "<a href=\"#{source}\">Download #{showname voo.title}</a>"
    end
  end

  view :editor do
    if card.web? || card.no_upload?
      return text_field(:content, class: "card-content")
    end
    file_chooser
  end

  def preview
    ""
  end

  view :preview_editor, tags: :unknown_ok, cache: :never do |args|
    cached_upload_card_name = Card::Env.params[:attachment_upload]
    cached_upload_card_name.gsub!(/\[\w+\]$/, "[action_id_of_cached_upload]")
    <<-HTML
      <div class="chosen-file">
        <input type="hidden" name="#{cached_upload_card_name}"
                             value="#{card.selected_action_id}">
        <table role="presentation" class="table table-striped">
          <tbody class="files">
            <tr class="template-download fade in">
              <td>
                <span class="preview">
                  #{preview}
                </span>
              </td>
              <td>
                <p class="name">
                  #{card.original_filename}
                </p>
              </td>
              <td>
                <span class="size">
                  #{number_to_human_size(card.attachment.size)}
                </span>
              </td>
              <td class="pull-right">
                <button class="btn btn-danger delete cancel-upload"
                        data-type="DELETE">
                  <i class="glyphicon glyphicon-trash"></i>
                  <span>Delete</span>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    HTML
  end

  def file_chooser
    <<-HTML
      <div class="choose-file">
        #{preview}
        <span class="btn btn-success fileinput-button">
            <i class="glyphicon glyphicon-cloud-upload"></i>
            <span>
                #{card.new_card? ? 'Add' : 'Replace'} #{card.attachment_name}...
            </span>
             <input class="file-upload slotter form-control" type="file"
                name="card[#{card.type_code}]" id="card_#{card.type_code}">
             #{hidden_field_tag 'attachment_type_id', card.type_id}
             #{hidden_field card.attachment_name, class: 'attachment_card_name',
                                                  value: ''}
             #{hidden_field_tag 'file_card_name', card.cardname.url_key}
        </span>
      </div>
      <div id="progress" class="progress" style="display: none;">
        <div class="progress-bar progress-bar-success" style="width: 0%;"></div>
      </div>
      <div class="chosen-file"></div>
    HTML
  end
end
