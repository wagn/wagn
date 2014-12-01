
view :raw do |args|
  File.read "#{Card.gem_root}/mod/03_machines/lib/stylesheets/standard.scss"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
