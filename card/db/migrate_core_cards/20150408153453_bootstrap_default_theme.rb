# -*- encoding : utf-8 -*-

class BootstrapDefaultTheme < Card::CoreMigration
  def up
    default = Card.fetch 'themeless bootstrap skin', :new=>{:type_code=>:skin}
    default.update_attributes! :content=> "[[style: jquery-ui-smoothness]]\n[[style: cards]]\n[[style: right sidebar]]\n[[style: bootstrap cards]]"
    bs = Card[:bootstrap_css]
    bs.update_attributes! :codename=>nil
    bs.delete!

    theme_name = "bootstrap_default"
    path = data_path "themes/#{theme_name}"
    theme = Card.fetch "theme: #{theme_name}"
    theme.update_attributes! :type_id=>Card::ScssID, :codename=>nil, :content => "{{+variables}}{{bootswatch shared}}", :subcards=> {
      "+variables" => {:type_code=>:scss, :content=>File.read(File.join path, '_variables.scss')},
    }
  end
end
