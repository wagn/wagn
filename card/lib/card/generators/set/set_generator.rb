class SetGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  argument :mod, :required => true 
  argument :set_pattern, :required => true
  argument :anchors, :required=>true, :type=>:array
  class_option :core, :type=>:boolean, :desc=>'create set files in Wagn gem'

    
  def create_files
    mod_path = if options.core?
        File.join Cardio.gem_root, 'mod', mod
      else
        File.join 'mod', mod
      end
    set_path  = File.join(mod_path, 'set', set_pattern, anchors[0..-2], "#{anchors.last}.rb")
    spec_path = File.join(mod_path, 'spec', 'set', set_pattern, anchors[0..-2], "#{anchors.last}_spec.rb" )
    template 'set_template.erb', set_path
    template 'set_spec_template.erb', spec_path
  end
  
end
