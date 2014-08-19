
view :raw do |args|
  File.read "#{Wagn.gem_root}/mod/02_machines/lib/stylesheets/standard.scss"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
