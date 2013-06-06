# -*- encoding : utf-8 -*-


module Wagn
  module Set::All::File
    extend Set

    format :file

    define_view :core do |args|
      'File rendering of this card not yet supported'
    end
    
    define_view :core, :type=>:file do |args|               # returns send_file args.  not in love with this...
      if format = card.attachment_format( params[:format] ) # this means we only support known formats.  dislike.       
       
  #      elsif ![format, 'file'].member? params[:format]    # formerly supported redirecting to correct file format 
  #        return redirect_to( request.fullpath.sub( /\.#{params[:format]}\b/, '.' + format ) ) #card.attach.url(style) )
  
        style  = _render_style :style=>params[:size]
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
    
    define_view( :style ) { |args| nil }
        
    define_view :style, :type=>:image do |args|  #should this be in model?
      ['', 'full'].member?( args[:style].to_s ) ? :original : args[:style]
    end
    
    
    alias_view :core, {:type=>:file}, {:type=>:image}    

  end
end