require 'rails/generators/active_record'

class CardMigrationGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :card_list, :type => :string, :default => nil

  def create_migration_file
    unless @card_list
      say_status "Failure", "no card_list file specified; see rails g card_migration --help", :red
      return false
    end 
    
    list = File.read @card_list
    namelist = list.split("\n").map do |cardname|
      cardname.strip!
      cardname.blank? ? nil : cardname
    end.compact
    
    unless namelist.any?
      say_status "Failure", "empty card list; see rails g card_migration --help", :red
      return false
    end
    
    broken = []
    @cards = namelist.map do |name|
      c = Card[name]
      broken << name if c.nil?
      c
    end
    if broken.any?
      say_status "Failure", "failed to find these cards: #{broken.inspect}", :red
    else
      say_status "Cards Found", "found #{@cards.count} cards"
      migration_template "migration.rb", "db/migrate/#{file_name}.rb"
    end
  end

  protected
#    attr_reader :migration_action

#    def set_local_assigns!
#      if file_name =~ /^(add|remove)_.*_(?:to|from)_(.*)/
#        @migration_action = $1
#        @table_name       = $2.pluralize
#      end
#    end

end



# attr_accessor :migration_name

# def manifest
#   record do |m|           
#     puts "CARD_NAME: #{card.name}"
#     puts "CONTENT:\n#{card.content}\n"      
#             
#     
#     @migration_name = "set_#{sanitized_name}"
#     n = 2
#     while migration_exists?(@migration_name)
#       @migration_name = "set_#{sanitized_name}_#{n}"
#       n += 1
#     end
#     
#     puts "MIGRATION_NAME: #{migration_name}"
#     
#     # ensure migration dir
#     m.directory File.join('db/migrate', class_path)
#     m.migration_template 'migration.rb.template',  'db/migrate', :migration_file_name=>migration_name
#   end
# end
# 
# def sanitized_name
#   file_name.to_name.key.gsub(/\*/,'star_').gsub(/\+/,'_plus_') 
# end
# 
# def card
#   Session.as_bot
#   @card||=Card[file_name]
# end
# 
# # borrowed this code from rails generator commands-- couldn't figure out how to invoke it from here   
# def migration_exists?(file_name)
#   not existing_migrations(file_name).empty?
# end      
# 
# def existing_migrations(file_name)
#   Dir.glob("#{migration_directory}/[0-9]*_*.rb").grep(/[0-9]+_#{file_name}.rb$/)
# end
# 
# def migration_directory 
#   "#{Rails.root}/db/migrate"
# end




#class NewCardMigrationGenerator < Rails::Generators::NamedBase
#  source_root File.expand_path('../templates', __FILE__)
#end
