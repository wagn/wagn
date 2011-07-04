class UpdateRelatedTabs < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    
    if c = Card['*reference']
      c.destroy!
    end
    
    YAML.load_file("#{RAILS_ROOT}/db/migration_data/updated_related_tab_cards.yml").each do |card_def|
      name, type, content, extension_type = card_def
      c = Card[name] || Card.create(:name=>name)
      c.type=type
      c.content=content
      c.extension_type=extension_type
      c.save
      c.permit(:edit, Role[:admin])
    end
    
    if c=Card['*tagged+*rform']
      c.extension_type=''
      c.save!
    end
  end

  # did this in console to create dump
  # data = cards.map{|c| [c.name, c.type, c.content, c.extension_type] }.to_yaml 
  # File.open("#{RAILS_ROOT}/db/migration_data/updated_related_tab_cards.yml", 'w') do |file|
  #   file.write data
  # end

  def self.down
  end
end
