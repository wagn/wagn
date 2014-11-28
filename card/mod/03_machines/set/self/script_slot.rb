view :raw do |args|
  [ "wagn_mod.js.coffee", "wagn.js.coffee" ].map do |name|
    File.read "#{Wagn.gem_root}/mod/03_machines/lib/javascript/#{name}"
  end.join("\n")
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
