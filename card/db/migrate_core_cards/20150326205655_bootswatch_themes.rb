# -*- encoding : utf-8 -*-

class BootswatchThemes < Card::CoreMigration
  def up
    #Card.create! :name=>'Bootswatch Theme', :type_code=>:cardtype, :codename=>'bootswatch_theme'
    #Card.create! :name=>'Bootswatch Theme+*type+*structure', :content=>'{{+variables}}{{+style}}'
    #Card::Cache.reset_global
    Card.create! :name=>'bootswatch shared', :type_code=>:scss, :codename=>'bootswatch_shared'
    
    %w{cerulean cosmo cyborg darkly flatly journal lumen paper readable sandstone simplex slate spacelab superhero united yeti }.each do |theme_name|
      path = data_path "themes/#{theme_name}"
      theme = Card.fetch "theme: #{theme_name}"
      if theme
        theme.update_attributes! :type_id=>Card::ScssID, :codename=>nil, :content => "{{+variables}}{{bootswatch shared}}{{+style}}", :subcards=> {
          "+variables" => {:type_code=>:scss, :content=>File.read(File.join path, '_variables.scss')},
          "+style"     => {:type_code=>:scss, :content=>File.read(File.join path, '_bootswatch.scss')}
        }
      else
        Card.create! :name=>"theme: #{theme}", :type_code=>:scss, :content => "{{+variables}}{{bootswatch shared}}{{+style}}", :subcards=> {
          "+variables" => {:type_code=>:scss, :content=>File.read(File.join path, '_variables.scss')},
          "+style"     => {:type_code=>:scss, :content=>File.read(File.join path, '_bootswatch.scss')}
        }
      end
    end
  end
end
