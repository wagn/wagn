require 'sass'
include Machine

store_machine_output :filetype => "css"

def chunk_list  #turn off autodetection of uri's 
                #TODO with the new format pattern this should be handled in the js format
    :inclusion_only
end

=begin
format :file do
  view :core do |args|
    if params[:explicit_file] and r = controller.response
      r.headers["Expires"] = 1.year.from_now.httpdate
    end
    
    [ card.style_file, { :filename=>"#{card.cardname.url_key}.css",
        :x_sendfile=>true, :type=>'text/css', :disposition=>'inline' } ]
  end
end
=end
