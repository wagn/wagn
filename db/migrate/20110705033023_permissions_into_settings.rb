class PermissionsIntoSettings < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card.reset_column_information
    Wagn::Cache.reset_global
    ENV['MIGRATE_PERMISSIONS'] = 'true'
    
    #some data cleanup for integrity issues that were causing problems here and there.
    execute "update cards set extension_type=null where extension_type in('SoftTemplate','HardTemplate')"
    execute "update cards set typecode='Basic' where not exists (select * from cardtypes where class_name = typecode)"
    
    ['all plus', 'star', 'rstar'].each do |set|
      Card.create :name=>"*#{set}", :type=>'Set'
    end
    
    [:create, :read, :update, :delete, :comment].each do |setting|
      Card.create :name=>"*#{setting}", :type=>'Setting'
    end
    
    [:create, :update, :delete].each do |task|
      ['*star','*rstar','HTML+*type', 'Cardtype+description+*type plus right' ].each do |set|
        create_rule(set, task, Role[:admin])
      end
    end

    create_rule('*watcher+*right', :create, Role[:auth])
    create_rule('*watcher+*right', :update, Role[:auth])

    all_role = {}
    [:create, :read, :edit, :delete, :comment].each do |task|
      puts "updating *all for #{task}"
      where = " name not like '*%' and tag_id is null "
      where += " and party_id is not null " if task == :create
      all_role[task] = most_common_party(task, where)
      all_rule = create_rule('*all',task, all_role[task])
      all_plus_rule = create_rule('*all plus', task, '_left') unless task==:comment
      if task == :read
        execute "update cards set read_rule_id=#{all_rule.id}, read_rule_class='*all' where trash is false and tag_id is null"
        execute "update cards set read_rule_id=#{all_rule.id}, read_rule_class='*all plus' where trash is false and tag_id is not null"
      end
    end
    
    puts "updating types for create"
    Card.search(:type=>'Cardtype').each do |typecard|
      next if typecard.key == 'html'
      begin
        create_role_for_type = typecard.permissions.reject { |perm| perm.task != 'create' }.first.party
      rescue
        puts "DATA ERROR: can't find create party for #{typecard.name}"
        next
      end
      next if create_role_for_type == all_role[:create]
      create_rule("#{typecard.name}+*type",'create', create_role_for_type)
    end

    puts "creating *type set perms"
    [:read, :edit, :delete, :comment].each do |task|
      Card.search(:type=>'Cardtype', :created_by=>{:not=>{:name=>["in","Wagn Bot","Admin"]}}).map do |typecard|
        next if typecard.key == 'html'
        type_ext = typecard.extension
        if type_ext.nil?
          puts "DATA ERROR: #{typecard.name} has no extension"
          next
        end
        if top_role_for_type = most_common_party(task, "name not like '*%' and tag_id is null and typecode='#{type_ext.class_name}'")
          next if !top_role_for_type || top_role_for_type==all_role[task]
          new_rule = create_rule("#{typecard.name}+*type",task,top_role_for_type)
          execute "update cards set read_rule_id=#{new_rule.id}, read_rule_class='*type' " + 
            " where trash is false and typecode='#{type_ext.class_name}'" if task == :read
        end
      end
    end

    puts "creating *right set perms"
    Card.find(:all, :conditions=>"(name like '%*right+*content' or name like '%right+*default') and trash is false").each do |card|
      next if card.cardname.star?
      base_name = card.name.gsub(/^(.*)\+\*right\+\*(content|default)$/, '\1')
      [:read, :edit, :delete, :comment].each do |task|
        begin
          could = card.who_could(task)
          can = Card.new(:name=>"XXXXXHONK+#{base_name}", :skip_defaults=>true).who_can(task==:edit ? :update : task)
          if could && could != can
            new_rule = create_rule "#{base_name}+*right", task, Card.fetch(could.first, :skip_modules=>true)
            execute "update cards set read_rule_id=#{new_rule.id}, read_rule_class='*right' " + 
              " where trash is false and tag_id=#{Card[base_name].id}" if task == :read
          end
        rescue
          puts "FAILURE creating #{card.name}+*right"
        end
      end
    end
    
    puts "creating *self set perms"
    wagn_dot_org = !!(Card.fetch('GC Staff') && Card.fetch('Wagn Is'))
    wdo_reserved_list = ['Deck','Report','Report1','Note','Lead','Client','Projects','Registration',
      'Grant Application','Meeting','TechNote','ProjectStatus','Company']
    
    Card.find(:all, :conditions=>'tag_id is null and trash is false').each do |card|
      next if card.cardname.star?
      next if wagn_dot_org && wdo_reserved_list.member?( card.typecode )
      [:read, :edit, :delete, :comment].each do |task|
        begin
          could = card.who_could(task)
          can = card.who_can(task==:edit ? :update : task)
          if could && could != can
            card.repair_key if card.key != card.name.to_key
            new_rule = create_rule "#{card.name}+*self", task, Card.fetch(could.first, :skip_modules=>true)
            execute "update cards set read_rule_id=#{new_rule.id}, read_rule_class='*self' " + 
              " where trash is false and id=#{card.id}" if task == :read
            
          end
        rescue Exception=>e
          fail "FAILURE creating #{card.name}+*self:\n  #{e.inspect}\n#{e.backtrace}\n"
        end
      end
    end
    ENV['MIGRATE_PERMISSIONS'] = 'false'
  end

  def self.down
    Card.search(:right=>{:name=>%w{ in *create *read *update *delete}})
  end
  
  def self.most_common_party(task, where)
    #note - the weird subselect is necessary to get zero counts on comments.
    sql =   %{ select count(*) as count, party_id from cards c left join
          (select card_id, party_id from permissions where task='#{task}') as p
        on p.card_id = c.id where #{where} and trash is false
        group by party_id order by count desc; }
    #puts "\nSQL = #{sql}\n"
    rows = ActiveRecord::Base.connection.select_all(sql)
    if rows.empty?
      #puts "nothing found for #{task}, #{where}"
      return false
    end
    party_id = rows.first['party_id']
    return '' if party_id.nil? || party_id.blank?
    Role[party_id.to_i]
  end
  
  def self.create_rule(set, task, party)
    role_card = nil
    content = case
      when party.nil?
        puts "CREATE_RULE FAILED: cannot accept nil party: #{set}, #{task}"
        return false
      when String===party; party
      when Card=== party
        role_card = party
        role = party.extension
        if role.nil?
          puts "CREATE_RULE FAILED: cannot find extension for #{party.name}: #{set}, #{task}"
          return false
        end
        "[[#{role.cardname}]]"
      when party == false
        puts "Bad rule false: #{set} #{task}"
        return false
      else
        role_card = party.card
         "[[#{party.cardname}]]"
      end
      
    puts "- create rule for #{set}, #{task.to_s.upcase}:  #{content}"
    cname = "#{set}+*#{task.to_s=='edit' ? 'update' : task}"
    Card.create(
      :name=>cname,
      :type=>'Pointer',
      :content=>content
    )
    c = Card[cname]
    puts "- created rule for #{set}, #{task.to_s.upcase}:  #{c&&c.id.inspect}, #{c&&c.name}"
    return c if String===party
    WikiReference.create(
      :card_id=>c.id, 
      :referenced_name=>role_card.key,
      :referenced_card_id=>role_card.id,
      :link_type => 'L' 
    )
    c
  end
end

class Permission < ActiveRecord::Base
  belongs_to :party, :polymorphic=>true
  belongs_to :card
end


class Card
  has_many :permissions, :foreign_key=>'card_id' 
  
  def who_could(operation)
    perm = permissions.reject { |perm| perm.task != operation.to_s }.first   
    perm && [perm.party.card.key] 
  end
end
