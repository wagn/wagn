view :raw do |_args|
  File.read "#{Cardio.gem_root}/mod/06_bootstrap/lib/stylesheets/#{card.codename}.scss"
end

format :html do
  view :editor do |_args|
    "Content is stored in file and can't be edited."
  end
end
