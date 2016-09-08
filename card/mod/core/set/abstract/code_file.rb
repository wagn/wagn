def self.included host_class
  host_class.mattr_accessor :file_content_mod_name
  host_class.file_content_mod_name = Card::Set.mod_name(caller)
end

# @return [Array<String>, String] the name of file(s) to be loaded
def source_files
  case type_id
  when CoffeeScriptID then "#{codename}.js.coffee"
  when JavaScriptID   then "#{codename}.js"
  when CssID          then "#{codename}.css"
  when ScssID         then "#{codename}.scss"
  end
end

def source_dir
  case type_id
  when CoffeeScriptID, JavaScriptID then "javascript"
  when CssID, ScssID then "stylesheets"
  end
end

def find_file filename
  mod_path = Card::Mod::Loader.mod_dirs.path file_content_mod_name
  file_path = File.join(mod_path, "lib", source_dir, filename)
  return unless File.exist? file_path
  file_path
end

def existing_source_paths
  Array.wrap(source_files).map do |filename|
    find_file(filename)
  end.compact
end

view :raw do |_args|
  Array.wrap(card.source_files).map do |filename|
    if (source_path = card.find_file(filename))
      Rails.logger.info "reading file: #{source_path}"
      File.read source_path
    else
      Rails.logger.info "couldn't locate file: #{filename}"
      nil
    end
  end.compact.join "\n"
end

format :html do
  view :editor do |_args|
    "Content is stored in file and can't be edited."
  end
end
