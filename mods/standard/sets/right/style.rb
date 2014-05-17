require 'sass'
include Machine

store_machine_output :filetype => "css"
    
format :file do
  view :core do |args|
    if params[:explicit_file] and r = controller.response
      r.headers["Expires"] = 1.year.from_now.httpdate
    end
    
    [ card.style_file, { :filename=>"#{card.cardname.url_key}.css",
        :x_sendfile=>true, :type=>'text/css', :disposition=>'inline' } ]
  end
end

