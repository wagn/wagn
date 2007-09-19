class ConvertPermissions < ActiveRecord::Migration
  class ::MCard < ActiveRecord::Base
    set_table_name 'cards'
    set_inheritance_column nil
    belongs_to :reader,   :polymorphic=>true
    belongs_to :writer,   :polymorphic=>true
    belongs_to :appender, :polymorphic=>true
    
    has_many :permissions, :foreign_key=>'card_id', :dependent=>:delete_all
  end
  def self.up
    auth = Role.find_by_codename 'auth'
    anon = Role.find_by_codename 'anon'
    MCard.find(:all).each do |c|
      #print "setting permission for #{c.name}"
      c.permissions= [
        {:task=>'delete', :party=>c.writer || auth},
        {:task=>'edit',   :party=>c.writer || auth},
        {:task=>'read',   :party=>c.reader || anon},
        {:task=>'comment',:party=>c.appender},
        ].map { |hash| Permission.new(hash)}     
    end
    MCard.find_by_key('basic').permissions << Permission.new({:task=>'create', :party=>auth}) 
  end

  def self.down
    delete 'delete from permissions'
  end
end
