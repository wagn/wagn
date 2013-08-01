class SetGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  argument :pack#, :required => true, :type => :array, :desc => "The names of the attachment(s) to add.",
             #:banner => "attachment_one attachment_two attachment_three ..."
  argument :set_pattern
  argument :anchor
  
#  pack/standard/sets/type/tshirt.rb
#  spec/pack/standard/sets/type/tshirt_spec.rb
  
  def create_files
    template 'set_template.erb',           "pack/#{pack}/sets/#{set_pattern}/#{anchor}.rb"
    template 'set_spec_template.erb', "spec/pack/#{pack}/sets/#{set_pattern}/#{anchor}_spec.rb"
  end
  
end
