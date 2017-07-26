STYLESHEETS_DIR = File.join(Cardio.gem_root, "mod",
                             file_content_mod_name, "lib",
                             "stylesheets").freeze
 BOOTSTRAP_PATH = File.join(STYLESHEETS_DIR, "bootstrap", "scss").freeze

 def read_dir sub_dir
   Dir.glob("#{BOOTSTRAP_PATH}/#{sub_dir}/*.scss").map do |name|
     File.read name
   end.join("\n")
 end
