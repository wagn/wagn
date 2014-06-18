
view :raw do |args|
  File.read "#{Wagn.gem_root}/mods/standard/lib/javascript/tinymce.js"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
