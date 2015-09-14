# -*- encoding : utf-8 -*-

class AdminInfoCard < Card::CoreMigration
  def up
    Card.create! :name=>"*admin info", :codename=>"admin_info", :subcards=>{'+*self+*read'=>'[[Administrator]]'}

    codenames = %w( default_html_view debugger recaptcha_settings )
    content = codenames.map {|cn| "[[#{cn}]]"}.join "\n"
    Card.create! :name=>"*admin settings", :codename=>"admin_settings",
      :type_id=>Card::PointerID, :content=>content,
      :subcards=>{'+*self+*read'=>'[[Administrator]]'}
  end
end
