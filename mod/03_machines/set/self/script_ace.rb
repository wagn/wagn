
view :raw do |args|  
  File.read "#{Wagn.gem_root}/mod/03_machines/lib/javascript/ace/ace.js"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
