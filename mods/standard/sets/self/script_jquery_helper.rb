
view :raw do |args|
  js_files = %w( jquerymobile.js jquery-ui.js jquery.ui.autocomplete.html.js jquery.autosize.js jquery.fileupload.js jquery.iframe-transport.js jquery_ujs.js )
  js_files.map do |filename|
    File.read "#{Wagn.gem_root}/mods/standard/lib/javascript/#{filename}"
  end.join("\n")
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
