
view :raw do |args|
  [ 
    File.read "#{Wagn.gem_root}/mods/standard/lib/javascript/wagn_mod.js.coffee",
    File.read "#{Wagn.gem_root}/mods/standard/lib/javascript/wagn.js"
  ].join
end

view :edCard::Auth.as_bot { c.save }itor do |args|
  "Content is stored in file and can't be edited."
end
