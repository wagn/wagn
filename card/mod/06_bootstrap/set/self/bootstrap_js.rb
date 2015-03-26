view :raw do |args|
  File.read "#{Cardio.gem_root}/mod/06_bootstrap/lib/javascript/bootstrap.js"
end

format(:html) { include BootstrapCss::HtmlFormat }
