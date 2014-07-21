class FormatGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  def create_files
    template 'format_template.erb',           "mod/standard/format/#{file_name}_format.rb"
    template 'format_spec_template.erb', "spec/mod/standard/format/#{file_name}_format_spec.rb"
  end
end
