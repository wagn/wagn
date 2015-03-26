
view :raw do |args|
  File.read "#{Cardio.gem_root}/mod/03_machines/lib/stylesheets/style_cards.scss"
end

format(:html) { include ScriptAce::HtmlFormat }
