Card.mount_uploader :file, FileUploader, :mount_on=>:db_content
Card.skip_callback :commit, :after, :remove_previously_stored_file
#  skip_callback :save, :before, :write_attach_identifier

def item_names(args={})  # needed for flexmail attachments.  hacky.
  [self.cardname]
end

def attachment
  file
end

def set_mod_source mod
  attachment.mod = mod
end

def use_mod_file! mod
  set_mod_source mod
  update_attributes! :content=>attachment.identifier
end

def original_filename
  attachment.original_filename
end

def symlink_to(prior_action_id) # create filesystem links to files from prior action
  # if prior_action_id != last_action_id
  #   save_action_id = selected_action_id
  #   links = {}
  #
  #   self.selected_action_id = prior_action_id
  #   attachment.versions.each do |name, version|
  #     links[name] = ::File.basename(version.path)
  #   end
  #   original = ::File.basename(attachment.path)
  #
  #   self.selected_action_id = last_action_id
  #   attachment.versions.each do |name, version|
  #     ::File.symlink links[name], version.path
  #   end
  #   ::File.symlink original, attachment.path
  #
  #   self.selected_action_id = save_action_id
  # end
end


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


event :save_original_filename, :before=>:create_card_changes do
  if @current_action
    @current_action.update_attributes! :comment=>original_filename
  end
end

event :move_file_to_store_dir, :after=>:store, :on=>:create do
  if ::File.exist? tmp_store_dir
    FileUtils.mv tmp_store_dir, store_dir
  end
  #if !(content =~ /^[:~]/)
    update_attributes! :content=>file.identifier
    #end
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
      [ card.attach.path( *[style].compact ),             # nil or empty arg breaks 1.8.7
        {
          :type => card.attach_content_type,
          :filename =>  "#{card.cardname.url_key}#{style.blank? ? '' : '-'}#{style}.#{format}",
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
    out = '<div class="choose-file">'
    if !card.new_card?
      out << %{<div class="attachment-preview" :id="#{card.attachment.filename}-preview"> #{_render_core(args)} </div> }
    end
    out << %{
      <div>#{file_field db_column, :class=>'file-upload slotter'}</div>
    </div>
    <div class="chosen-file" style="display:none">
      <div><label>File chosen:</label> <span class="chosen-filename"></span></div>
      <div><a class="cancel-upload">Unchoose</a></div>
    </div>
      }
    out
  end

end



