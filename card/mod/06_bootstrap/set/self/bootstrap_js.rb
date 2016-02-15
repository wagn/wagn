view :raw do |args|
  [ "bootstrap.js", "bootstrap_modal_wagn.js" ].map do |name|
    File.read "#{Cardio.gem_root}/mod/06_bootstrap/lib/javascript/#{name}"
  end.join("\n")
end

format(:html) { include BootstrapCards::HtmlFormat }
