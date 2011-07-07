class PermissionsIntoSettings < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Wagn::Cache.reset_global
    ENV['BOOTSTRAP_LOAD'] = 'true'
    
    execute "update cards set extension_type=null where extension_type in('SoftTemplate','HardTemplate')"
    
    [:create, :read, :update, :delete, :comment].each do |setting|
      Card.create :name=>"*#{setting}", :type=>'Setting'
    end
    
    [:create, :update, :delete].each do |task|
      ['*star','*rstar','HTML+*type'].each do |set|
        create_rule(set, task, Role[:admin])
      end
    end

    create_rule('*watcher+*right', :create, Role[:auth])
    create_rule('*watcher+*right', :update, Role[:auth])
    
    [:create, :read, :edit, :delete, :comment].each do |task|
      puts "updating *all for #{task}"
      
      all_role = most_common_party(task, "tag_id is null")
      create_rule('*all',task, all_role)
      create_rule('*all plus', task, '_left')
      
      puts "updating types for #{task}"
      if task == :create
        Card.search(:type=>'Cardtype').each do |typecard|
          next if typecard.key == 'html'
          begin
            create_role_for_type = typecard.permissions.reject { |perm| perm.task != 'create' }.first.party
          rescue
            puts "DATA ERROR: can't find create party for #{typecard.name}"
            next
          end
          next if create_role_for_type == all_role
          create_rule("#{typecard.name}+*type",'create', create_role_for_type)
        end
        next
      end
      
      Card.search(:type=>'Cardtype', :created_by=>{:not=>{:name=>["in","Wagn Bot","Admin"]}}).map do |typecard|
        next if typecard.key == 'html'
        type_ext = typecard.extension
        if type_ext.nil?
          puts "DATA ERROR: #{typecard.name} has no extension"
          next
        end
        puts "looking up top #{task} role for #{typecard.name}"
        if top_role_for_type = most_common_party(task, "tag_id is null and typecode='#{type_ext.class_name}'")
          next if !top_role_for_type || top_role_for_type==all_role
          create_rule("#{typecard.name}+*type",task,top_role_for_type)
        end
      end
    end
    
    
    puts 'updating read_rule fields'
    Card.find(:all).each do |card|
      begin
        card.update_read_rule
      rescue Exception => e
        puts "ERROR: failed to update read_rule for #{card.name} :  #{e.backtrace*"\n"} "
      end
    end
    ENV['BOOTSTRAP_LOAD'] = 'false'
  
  # FIGURE OUT COMMENTS 
  # DEAL WITH ODDBALLS 
  # hide updates (from recent changes)
    
  end

  def self.down
    Card.search(:right=>{:name=>%w{ in *create *read *update *delete}})
  end
  
  def self.most_common_party(task, where='')
    where = " and #{where} " if !where.blank?
    rows = ActiveRecord::Base.connection.select_all(
      "select count(*) as count, party_id from cards c join permissions p on p.card_id = c.id " + 
      "where task='#{task}' and name not like '*%' #{where} " +
      "group by party_id order by count desc"
    )
    if rows.empty?
      puts "nothing found for #{task}, #{where}"
      return false
    end
    party_id = rows.first['party_id']
    Role[party_id.to_i]
  end
  
  def self.create_rule(set, task, party)
    puts "create rule for #{set}, #{task}:  #{party}"
    c = Card.create(
      :name=>"#{set}+*#{task.to_s=='edit' ? 'update' : task}",
      :type=>'Pointer',
      :content=>(party=='_left' ? party : "[[#{party.cardname}]]")
    )
    return if party=='_left'
    role_card = party.card
    WikiReference.create(
      :card_id=>c.id, 
      :referenced_name=>role_card.key,
      :referenced_card_id=>role_card.id,
      :link_type => 'L' 
    )
  end
end
