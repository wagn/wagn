def mod_name
  path_parts = File.dirname(__FILE__).split(File::SEPARATOR)
  path_parts[path_parts.index('set')+1].match(/^mod\d+-(.+)$/)
  $1
end

def path
  @path ||= begin
    dir, filename =
      case type_id
      when CoffeeScriptID then ['javascript', "#{codename}.js.coffee"]
      when JavaScriptID then ['javascript', "#{codename}.js"]
      when CssID then ['stylesheets', "#{codename}.css"]
      when ScssID then ['stylesheets', "#{codename}.scss"]
      end
    mod =  mod_name
    Card.paths['mod'].to_a.each do |mod_path|
      file_path = File.join(mod_path, mod, 'lib', dir, filename)
      return file_path if File.exist? file_path
    end
  end
end

view :raw do |_args|
  Rails.logger.info "reading file: #{path}"
  File.read "#{path}"
end

format :html do
  view :editor do |_args|
    "Content is stored in file and can't be edited."
  end
end