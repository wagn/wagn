
view :raw do |_args|
  File.read "#{Cardio.gem_root}/mod/03_machines/lib/stylesheets/style_cards.scss"
end

format(:html) { include ScriptAce::HtmlFormat }
