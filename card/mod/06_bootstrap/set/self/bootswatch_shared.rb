include_set Abstract::CodeFile

view :raw do |_args|
  bootstrap_path = File.join Cardio.gem_root, "mod",
                             card.file_content_mod_name, "lib",
                             "stylesheets", "bootstrap"

  # variables
  content = File.read("#{bootstrap_path}/_variables.scss")
  content += %(
      $bootstrap-sass-asset-helper: false;
      $icon-font-path: "#{card_path 'assets/fonts/'}";
    )
  # mixins
  content += Dir.glob("#{bootstrap_path}/mixins/*.scss").map do |name|
    File.read name
  end.join("\n")
  content += [
    # Reset and dependencies
    %w(normalize print glyphicons),
    # Core CSS
    %w(scaffolding type code grid tables forms buttons),
    # Components
    %w(component-animations dropdowns button-groups input-groups navs navbar
       breadcrumbs pagination pager labels badges jumbotron thumbnails alerts
       progress-bars media list-group panels responsive-embed wells close),
    # Components w/ JavaScript
    %w(modals tooltip popovers carousel),
    # Utility classes
    %w(utilities responsive-utilities)
  ].map do |names|
    names.map do |name|
      path = File.join(bootstrap_path, "_#{name}.scss")
      Rails.logger.info "reading file: #{path}"
      File.read path
    end.join "\n"
  end.join "\n"

  content
end
