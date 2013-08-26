# -*- encoding : utf-8 -*-

  
def item_names(args={})  # needed for flexmail attachments.  hacky.
  [self.cardname]
end


format do
  view :source do |args|
    card.attach.url
  end

  view :core do |args|
    handle_source args do |source|
      wagn_url source
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
      
  view :core do |args|               # returns send_file args.  not in love with this...
    if format = card.attachment_format( params[:format] ) # this means we only support known formats.  dislike.       
   
  #      elsif ![format, 'file'].member? params[:format]    # formerly supported redirecting to correct file format 
  #        return redirect_to( request.fullpath.sub( /\.#{params[:format]}\b/, '.' + format ) ) #card.attach.url(style) )

      style = _render_style :style=>params[:size]
      [ card.attach.path( *[style].compact ), #nil or empty arg breaks 1.8.7
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
  
end



