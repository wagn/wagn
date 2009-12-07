namespace :wagn do
  task :stow_pattern => :environment do
    User.as :wagbot         
    cardname = "Pattern"
    Card[cardname].update_attribute :name, "#{cardname}5"   
    class_name = Card["#{cardname}5"].extension.class_name
    Cardtype.find_by_class_name(class_name).update_attribute :class_name, "#{cardname}5"
    Card.update_all "type='#{cardname}5'",     ["type='#{class_name}'"]
  end
  
  task :unstow_pattern => :environment do
    Card["Pattern5"].update_attribute :name, "Pattern"
  end
end