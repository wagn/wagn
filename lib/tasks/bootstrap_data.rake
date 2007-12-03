namespace :wagn do
  task :dump_bootstrap_data => :environment do
    sql = "SELECT * FROM %s"
    skip_tables = ["schema_info"]
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      i = "000"
      File.open("#{RAILS_ROOT}/db/bootstrap/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end
  
  task :load_bootstrap_data => :environment do
    require 'active_record/fixtures'
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    Dir.glob(File.join(RAILS_ROOT, 'db', 'bootstrap', '*.{yml,csv}')).each do |fixture_file|
      Fixtures.create_fixtures('db/bootstrap', File.basename(fixture_file, '.*'))
    end
  end

end



=begin

      ### Create basic data

      ## Start with users
      admin_user = User.create!( 
        :login => 'admin',
        :crypted_password => '6e18b8a0b17799cb6d4a10b6dd1e870b073051b1',
        :salt => 'bf2a748b23e6fc6fa64d5acb99df8e72e308c58c',
        :email => 'webmaster@nowhere.org',
        :invited_by=>nil 
      )
      User.login_as :admin

      anonymous_user = ::User.create( 
        :login => 'anonymous',
        :crypted_password => '13d124f96e2953fea135c13df097fb3d754588be',
        :salt => 'c420fa40c65a38186deb25ba859edacd9bf7d8f8',
        :email => 'anonymous@nowhere.org',
        :status => 'system',
        :invited_by=>1
      )   

      wagn_bot_user = User.create!( 
        :login => 'wagnbot',
        :crypted_password => '13d124f96e2953fea135c13df097fb3d754588be',
        :salt => 'c420fa40c65a38186deb25ba859edacd9bf7d8f8',
        :email => 'hoozebot@nowhere.org',
        :activated_at=>Time.now(),
        :invited_by=>1
      )


      # then setup default card permissions

    Card::User.create :name=>"Hooze Bot"
    Card::User.create :name=>"Anonymous"
    Card::User.create :name=>"Admin"   

    # make sure that we get create permissions set on cardtypes   
    Card::Cardtype.create :name=>"Cardtype"
    Card::Cardtype.create :name=>"Role"
    Card::Cardtype.create :name=>"Setting"
    Card::Cardtype.create :name=>"Currency"
    Card::Cardtype.create :name=>"Date"
    Card::Cardtype.create :name=>"File"
    Card::Cardtype.create :name=>"Image"
    Card::Cardtype.create :name=>"Number"
    Card::Cardtype.create :name=>"Percentage"
    Card::Cardtype.create :name=>"PlainText"
    Card::Cardtype.create :name=>"Ruby"
    Card::Cardtype.create :name=>"Pointer"
    Card::Cardtype.create :name=>"Script"
    Card::Cardtype.create :name=>"RichText"
    Card::Cardtype.create :name=>"InvitationRequest"
    Card::Cardtype.create :name=>"Search"
    Card::Cardtype.create :name=>"Company"
    Card::Cardtype.create :name=>"User"   

    Card::Role.create :name=>"Anyone Signed In"
    Card::Role.create :name=>"Anyone"

    Card::Cardtype.create :name=>"Basic"

    def_perm = {:read=>anon, :edit=> auth, :comment=> nil, :delete=> auth, :create=> auth}
    unless Card['*template']
      perm = def_perm.keys.map do |key|
        Permission.new :task=>key.to_s, :party=>def_perm[key]
      end
      t = Card.create! :name=>'*template', :permissions=> perm
    end

    # create a new list of permissions, otherwise the old ones just get their card_id reassigned
    perm = def_perm.keys.map do |key|
      Permission.new :task=>key.to_s, :party=>def_perm[key]
    end
    bt = Card.create! :name=>'Basic+*template', :permissions=>perm


  


      Card::Basic.create :name=>"*plus parts"
      Card::Basic.create :name=>"*cards that include"
      Card::Basic.create :name=>"Wagn"
      Card::Basic.create :name=>"*type cards"
      Card::Basic.create :name=>"*cards linked to"
      Card::Basic.create :name=>"*template"
      Card::Basic.create :name=>"Basic+*template"
      Card::Basic.create :name=>"*cards"
      Card::Basic.create :name=>"*cards included"
      Card::Basic.create :name=>"*plus cards"
      Card::Basic.create :name=>"*cards linked from"  




     # Create search cards. FIXME? should these be in code instead of db?
     {
        "*plus cards" => { :part =>"_self" },
        "*plus parts" => { :plus => "_self" },
        "*type cards"    => { :type =>"_self" },
        "*cards linked to"    => { :linked_to_by =>"_self" },
        "*cards linked from"  => { :link_to => "_self" },
        "*cards included"     => { :included_by =>"_self" },
        "*cards that include" => { :include =>"_self" },
      }.each do |name, spec|
        Card::Search.create! :name=>"#{name}+*template", 
          :content=>spec.to_json, :extension_type=>'HardTemplate'
      end

      Card::Setting.create :name=>"Thank You"                            

      Card::InvitationRequest.create :name=>"InvitationRequest+*template"
      # set special permissions for invitation request
      def_perm = {:read=>anon, :edit=> Role[:admin], :comment=> nil, :delete=> auth, :create=> anon}  
      perm = def_perm.keys.map do |key|
        Permission.new :task=>key.to_s, :party=>def_perm[key]
      end
      temp = Card::InvitationRequest.create! :name=>'InvitationRequest+*template', :permissions=> perm, :email=>'fake@fake.com'
    
  end
end          
=end
