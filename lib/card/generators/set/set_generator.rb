class SetGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  argument :mod#, :required => true, :type => :array, :desc => "The names of the attachment(s) to add.",
             #:banner => "attachment_one attachment_two attachment_three ..."
  argument :set_pattern
  argument :anchor
    
  def create_files
    template 'set_template.erb',           "mod/#{mod}/set/#{set_pattern}/#{anchor}.rb"
    template 'set_spec_template.erb', "spec/mod/#{mod}/set/#{set_pattern}/#{anchor}_spec.rb"
  end
  
end
