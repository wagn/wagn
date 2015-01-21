view :raw do |args|
  File.read "#{Wagn.gem_root}/mod/06_bootstrap/lib/stylesheets/darkly.css"
end

format :html do
  view :editor do |args|
    "Content is stored in file and can't be edited."
  end
end