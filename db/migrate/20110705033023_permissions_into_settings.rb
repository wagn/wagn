class PermissionsIntoSettings < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card.reset_column_information
    Wagn::Cache.reset_global
    ENV['BOOTSTRAP_LOAD'] = 'true'
    
    execute "update cards set extension_type=null where extension_type in('SoftTemplate','HardTemplate')"
    
    ['all plus', 'star', 'rstar'].each do |set|
      Card.create :name=>"*#{set}", :type=>'Set'
    end
    
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

    all_role = {}
    [:create, :read, :edit, :delete, :comment].each do |task|
      puts "updating *all for #{task}"
      where = " name not like '*%' and tag_id is null "
      where += " and party_id is not null " if task == :create
      all_role[task] = most_common_party(task, where)
      create_rule('*all',task, all_role[task])
      create_rule('*all plus', task, '_left')
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

    [:read, :edit, :delete, :comment].each do |task|
      puts "updating types for #{task}"
      Card.search(:type=>'Cardtype', :created_by=>{:not=>{:name=>["in","Wagn Bot","Admin"]}}).map do |typecard|
        next if typecard.key == 'html'
        type_ext = typecard.extension
        if type_ext.nil?
          puts "DATA ERROR: #{typecard.name} has no extension"
          next
        end
        if top_role_for_type = most_common_party(task, "name not like '*%' and tag_id is null and typecode='#{type_ext.class_name}'")
          next if !top_role_for_type || top_role_for_type==all_role[task]
          create_rule("#{typecard.name}+*type",task,top_role_for_type)
        end
      end
    end
    
    puts "updating comment tags"
    rows = ActiveRecord::Base.connection.select_all(
      %{ select t.name as tag_name, t.id as tag_id, count(*) from cards c 
        join permissions p on c.id=p.card_id 
        join cards t on c.tag_id = t.id 
        where task = 'comment' group by t.name, t.id
        having count(*) > 1   })
    rows.each do |row|
      tag_name, tag_id = row['tag_name'], row['tag_id']
      tag_party = most_common_party(:comment, " tag_id = #{tag_id}")
      if tag_party and !tag_party.blank?
        create_rule("#{tag_name}+*right",:comment, tag_party)
      end
    end
    
#    puts 'updating read_rule fields'
#    Card.find(:all).each do |card|
#      card.update_read_rule
#    end

    ENV['BOOTSTRAP_LOAD'] = 'false'
  # FIGURE OUT COMMENTS 
  # DEAL WITH ODDBALLS 
  end

  def self.down
    Card.search(:right=>{:name=>%w{ in *create *read *update *delete}})
  end
  
  def self.most_common_party(task, where)
    #note - the weird subselect is necessary to get zero counts on comments.
    sql =   %{ select count(*) as count, party_id from cards c left join
          (select card_id, party_id from permissions where task='#{task}') as p
        on p.card_id = c.id where #{where}
        group by party_id order by count desc; }
    #puts "\nSQL = #{sql}\n"
    rows = ActiveRecord::Base.connection.select_all(sql)
    if rows.empty?
      puts "nothing found for #{task}, #{where}"
      return false
    end
    party_id = rows.first['party_id']
    return '' if party_id.nil? || party_id.blank?
    Role[party_id.to_i]
  end
  
  def self.create_rule(set, task, party)
    puts "create rule for #{set}, #{task}:  #{party}"
    c = Card.create(
      :name=>"#{set}+*#{task.to_s=='edit' ? 'update' : task}",
      :type=>'Pointer',
      :content=>(String===party ? party : "[[#{party.cardname}]]")
    )
    return if String===party
    role_card = party.card
    WikiReference.create(
      :card_id=>c.id, 
      :referenced_name=>role_card.key,
      :referenced_card_id=>role_card.id,
      :link_type => 'L' 
    )
  end
end
