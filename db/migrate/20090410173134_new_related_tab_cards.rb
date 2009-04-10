class NewRelatedTabCards < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    YAML.load_file("#{RAILS_ROOT}/db/migration_data/related_tab_cards.yml").each do |card_def|
      name, type, content, extension_type = card_def
      unless Card[name]
        c = Card.create!(:name=>name, :type=>type, :content=>content, :extension_type=>extension_type)
        c.permit(:edit, Role[:admin])
      end
    end
  end

  def self.down
  end
end
