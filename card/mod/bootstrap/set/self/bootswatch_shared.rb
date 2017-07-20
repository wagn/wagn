 include_set Abstract::CodeFile

 STYLESHEETS_DIR = File.join(Cardio.gem_root, "mod",
                             file_content_mod_name, "lib",
                             "stylesheets").freeze
 BOOTSTRAP_PATH = File.join(STYLESHEETS_DIR, "bootstrap", "scss").freeze

 def read_dir sub_dir
   Dir.glob("#{BOOTSTRAP_PATH}/#{sub_dir}/*.scss").map do |name|
     File.read name
   end.join("\n")
 end

 view :raw do |_args|
   content = File.read File.join(STYLESHEETS_DIR, "font-awesome.css")
   content += File.read File.join(STYLESHEETS_DIR, "material-icons.css")
   return content
   #return File.read(File.join(STYLESHEETS_DIR, "bootstrap.css"))
   # variables
   content = File.read("#{BOOTSTRAP_PATH}/_variables.scss")
   content += %(
      $bootstrap-sass-asset-helper: false;
      $icon-font-path: "#{card_url 'assets/fonts/'}";
    )
   # mixins
   content += File.read File.join(BOOTSTRAP_PATH, "_mixins.scss")
   content += card.read_dir("mixins")

   content += [
     %w[custom],
     # Reset and dependencies
     %w[normalize print],
     # Core CSS
     %w[reboot type images code grid tables forms buttons],
     # Components
     %w[transitions dropdown button-group input-group custom-forms nav navbar card
       breadcrumb pagination badge jumbotron alert progress media list-group
       responsive-embed close],
     # Components w/ JavaScript
     %w[modal tooltip popover carousel]
   ].map do |names|
     names.map do |name|
       path = File.join(BOOTSTRAP_PATH, "_#{name}.scss")
       Rails.logger.info "reading file: #{path}"
       File.read path
     end.join "\n"
   end.join "\n"

   # Utility classes
   content += card.read_dir("utilities")

   content += File.read File.join(STYLESHEETS_DIR, "font-awesome.css")
   content
end
