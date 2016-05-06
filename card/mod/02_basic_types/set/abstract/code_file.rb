def self.included host_class
  # extract the mod name from the path of the set's tmp file
  # the caller that included the set file is set.rb
  # seems like the actual set file is in fourth position in
  # the backtrace but I'm not 100% sure if that is always the case
  path, = caller[4].partition(':')
  path_parts = path.split(File::SEPARATOR)
  mod_dir = path_parts[path_parts.index('set') + 1]
  raise Card::Error, "not a set path: #{path}" unless mod_dir
  match = mod_dir.match(/^mod\d+-(?<mod_name>.+)$/)
  host_class.mattr_accessor :file_content_mod_name
  host_class.file_content_mod_name = match[:mod_name]
end

# @return [Array<String>, String] the name of file(s) to be loaded
def source_files
  case type_id
  when CoffeeScriptID then "#{codename}.js.coffee"
  when JavaScriptID then "#{codename}.js"
  when CssID then "#{codename}.css"
  when ScssID then "#{codename}.scss"
  end
end

def source_dir
  case type_id
  when CoffeeScriptID, JavaScriptID then 'javascript'
  when CssID, ScssID then 'stylesheets'
  end
end

def find_file filename
  Card.paths['mod'].to_a.each do |mod_path|
    file_path =
      File.join(mod_path, file_content_mod_name, 'lib', source_dir, filename)
    return file_path if File.exist? file_path
  end
  nil
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
