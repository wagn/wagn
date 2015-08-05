include Abstract::Attachment

set_specific_attributes :file
mount_uploader :file, FileUploader

format do
  view :source do |args|
    card.attachment.url
  end

  view :core do |args|
    handle_source args do |source|
      card_url source
    end
  end

  def handle_source args
    source = _render_source args
    source ? yield( source ) : ''
  rescue
    'File Error'
  end
end



format :file do

  view :core do |args|                                    # returns send_file args.  not in love with this...
    if format = card.attachment_format( params[:format] ) # this means we only support known formats.  dislike.
      if params[:explicit_file] and r = controller.response
        r.headers["Expires"] = 1.year.from_now.httpdate
        #r.headers["Cache-Control"] = "public"            # currently using default "private", because proxy servers could block needed permission checks
      end


  #      elsif ![format, 'file'].member? params[:format]  # formerly supported redirecting to correct file format
  #        return redirect_to( request.fullpath.sub( /\.#{params[:format]}\b/, '.' + format ) ) #card.attach.url(style) )

      style = _render_style :style=>params[:size]         # fixme, shouldn't be in type file
      file = (style && style != :original) ? card.attachment.versions[style] : card.attachment
      [ file.path,
        {
          :type => file.content_type,
          :filename =>  file.filename,
          :x_sendfile => true,
          :disposition => (params[:format]=='file' ? 'attachment' : 'inline' )
        }
      ]
    else
      _render_not_found
    end
  end

end


format :html do

  view :core do |args|
    handle_source args do |source|
      "<a href=\"#{source}\">Download #{ showname args[:title] }</a>"
    end
  end

  view :editor do |args|
    #Rails.logger.debug "editor for file #{card.inspect}"
    file_chooser args
  end

  def file_chooser args, db_column=:file
    preview =
      if !card.new_card?
        content_tag :div, _render_core(args).html_safe,
          :class=>'attachment-preview', :id=>"#{card.attachment.filename}-preview"
      end

    <<-HTML
      <div class="choose-file">
        #{preview}
        <div>#{file_field db_column, :class=>'file-upload slotter'}</div>
      </div>
      <div class="chosen-file" style="display:none">
        <div>
          <label>File chosen:</label>
          <span class="chosen-filename"></span>
        </div>
        <div><a class="cancel-upload">Unchoose</a></div>
      </div>
    HTML
  end

end


