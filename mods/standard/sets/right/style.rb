require 'sass'
include Machine

store_machine_output :filetype => "css"
    
# Is this issue still relevant with the new machine approach?    
#FIXME - the following could be unified with type/file.rb considerably

# note that this was formerly accomplished as a separate File card (eg *all+*style+file).  The issue was that the permanent
# file regularly caused problems with non-root wagns, and requiring users to re-save the *all+*style rule upon updates
# to CSS, SCSS, and Skin cards was not popular.


format :file do
  view :core do |args|
    if params[:explicit_file] and r = controller.response
      r.headers["Expires"] = 1.year.from_now.httpdate
    end
    
    [ card.style_file, { :filename=>"#{card.cardname.url_key}.css",
        :x_sendfile=>true, :type=>'text/css', :disposition=>'inline' } ]
  end
end

