view :raw do |args|
  [ "wagn_mod.js.coffee", "wagn.js.coffee" ].map do |name|
    File.read "#{Cardio.gem_root}/mod/03_machines/lib/javascript/#{name}"
  end.join("\n")
end

format(:html) { include ScriptAce::HtmlFormat }
