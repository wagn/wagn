
format do
  def filename
    "#{card.codename}.scss"
  end

  view :raw do |args|
    File.read "#{Wagn.gem_root}/mod/06_bootstrap/lib/stylesheets/#{filename}"
  end

  view :editor do |args|
    "Content is stored in file and can't be edited."
  end
  
end