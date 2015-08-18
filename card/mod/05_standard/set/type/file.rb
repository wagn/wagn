attachment :file, :uploader=>FileUploader

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
  #        return redirect_to( request.fullpath.sub( /\.#{params[:format]}\b/, '.' + format ) ) #card.attachment.url(style) )

      file = selected_file_version
      [ file.path,
        {
          :type => file.content_type,
          :filename =>  "#{card.cardname.safe_key}#{file.extension}",
          :x_sendfile => true,
          :disposition => (params[:format]=='file' ? 'attachment' : 'inline' )
        }
      ]
    else
      _render_not_found
    end
  end

  def selected_file_version
    card.attachment
  end

end


format :html do

  view :core do |args|
    handle_source args do |source|
      "<a href=\"#{source}\">Download #{ showname args[:title] }</a>"
    end
  end

  view :editor do |args|
    file_chooser args
  end


  def preview  args
    if !card.new_card?
      <<-HTML
      <div>
        <label>File chosen:</label>
        <span class="chosen-filename">#{card.original_filename}</span>
      </div>
      HTML
    end
  end

  view :preview_editor do |args|
    <<-HTML
      <div class="chosen-file">
        #{preview(args)}
        <input type="hidden" name="cached_upload" value="#{card.name}">
        <div><a class="cancel-upload">Unchoose</a></div>
      </div>
    HTML
  end

  def file_chooser args
    <<-HTML
      <div class="choose-file">
        #{preview(args)}
        <div>#{file_field card.attachment_name, :class=>'file-upload slotter'}</div>
      </div>
      <div class="chosen-file">
      </div>
      <div id="progress" class="progress"><div class="progress-bar" style="width: 0%;"></div></div>

      <script>
      #{ ::CoffeeScript.compile ::File.read('/opt/wagn/card/mod/05_standard/lib/chooseFile.js.coffee')}
      </script>
    HTML
  end

end


