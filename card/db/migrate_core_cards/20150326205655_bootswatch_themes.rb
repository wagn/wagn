# -*- encoding : utf-8 -*-

class BootswatchThemes < Card::CoreMigration
  def up
    Card.create! :name=>'Bootswatch Theme', :type_code=>:cardtype, :codename=>'bootswatch_theme'
    Card.create! :name=>'Bootswatch Theme+*type+*structure', :content=>'{{+variables}}{{+style}}'
    %w{cerulean cosmo cyborg darkly flatly journal lumen paper readable sandstone simplex slate spacelab superhero united yeti }.each do |theme_name|
      path = data_path "themes/#{theme_name}"
      theme = Card.fetch "theme: #{theme_name}"
      if theme
        theme.update_attributes! :type_code=>:bootswatch_theme, :codename=>nil, :subcards=> {
          "+variables" => {:type_code=>:scss, :content=>File.read(File.join path, '_variables.scss')},
          "+style"     => {:type_code=>:scss, :content=>File.read(File.join path, '_bootswatch.scss')}
        }
      else
        Card.create! :name=>"theme: #{theme}", :type_code=>:bootswatch_theme, :subcards=> {
          "+variables" => {:type_code=>:scss, :content=>File.read(File.join path, '_variables.scss')},
          "+style"     => {:type_code=>:scss, :content=>File.read(File.join path, '_bootswatch.scss')}
        }
      end
  end
end
