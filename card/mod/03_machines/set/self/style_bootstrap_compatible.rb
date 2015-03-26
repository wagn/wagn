view :raw do |args|
  File.read "#{Cardio.gem_root}/mod/03_machines/lib/stylesheets/#{card.codename}.css"
end

format(:html) { include ScriptAce::HtmlFormat }
