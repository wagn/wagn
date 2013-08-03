class FormatGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  def create_files
    template 'format_template.erb',           "pack/standard/sets/#{file_name}.rb"
    template 'format_spec_template.erb', "spec/pack/standard/sets/#{file_name}_spec.rb"
  end
end
