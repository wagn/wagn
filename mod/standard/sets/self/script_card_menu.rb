
view :raw do |args|
  File.read "#{Wagn.gem_root}/mods/standard/lib/javascript/wagn_menu.js"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
