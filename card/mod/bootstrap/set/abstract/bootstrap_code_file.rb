def self.included host_class
  host_class.include_set Abstract::CodeFile
  host_class.mattr_accessor :stylesheets_dir, :bootstrap_path
  host_class.stylesheets_dir =
    File.join(Cardio.gem_root, "mod",
              host_class.file_content_mod_name, "lib", "stylesheets")
  host_class.bootstrap_path =
    File.join(host_class.stylesheets_dir, "bootstrap", "scss")
end

def add_bs_subdir sub_dir
  Dir.glob("#{bootstrap_path}/#{sub_dir}/*.scss").each do |path|
    load_from_path path
  end
end

def add_stylesheet filename, type: :scss
  load_from_path File.join(stylesheets_dir, "#{filename}.#{type}")
end

def add_bs_stylesheet filename, type: :scss, subdir: nil
  path = File.join(*[bootstrap_path, subdir, "_#{filename}.#{type}"].compact)
  load_from_path path
end

def load_from_path path
  @stylesheets ||= []
  Rails.logger.info "reading file: #{path}"
  @stylesheets << File.read(path)
end

def stylesheets
  load_stylesheets unless @stylesheets
  @stylesheets
end

view :raw do |_args|
  card.stylesheets.join "\n"
end
