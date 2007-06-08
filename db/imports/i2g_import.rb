module I2gImport
  DB = {
      :adapter => "postgresql",
      :host => "localhost",
      :username => "herd",
      :password => "herd",
      :database => "ig-live"
    }
    
  class Body < ActiveRecord::Base; set_table_name 'body'; self.establish_connection DB;  end
  class User < ActiveRecord::Base; self.establish_connection DB;  end
  class RootCard < ActiveRecord::Base; self.establish_connection DB;  end
  class TagCard < ActiveRecord::Base; self.establish_connection DB;  end
  
  class Importer
    def db() Body.connection end
    
    def clear
      %w[nodes tag_revisions revisions wiki_references cards tags users ].each do |table|
        ::User.connection.delete %{ delete from "#{table}" }
      end
    end
    
    def import( max = 20 )
      ::System.setup
      import_users
      import_bodies( max )
      import_root_cards( max )
      import_tag_cards( max )
    end
    
    def import_company_names
      hoozebot = ::WagBot.instance
      ::Node::Company.find(:all).each_with_index do |company,i| 
        if body = Body.find_by_name_tag( company.name )
          if body.nick_name.length > 3 and body.nick_name != company.name
            warn "#{i} #{company.name} -> #{body.nick_name}"
            company.rename( body.nick_name, Time.now(), hoozebot  )
          end
        end
      end
    end
    
    
    def import_users
      User.find(:all).each_with_index do |old_user,i|
        new_user = ::User.new({
          :login => old_user.login,
          :email => "#{old_user.login}@fakemail.com",
          :crypted_password => old_user.password,
          :invited_by=>1,
          :name => old_user.name_tag
        })
        new_user.build_tag_with_proxy_attributes
        if !new_user.save
          warn new_user.errors.plot(:join, ' ').join(',')
        else
          warn "User #{i}: #{old_user.login}"
        end
      end
    end
    
    def import_bodies( limit = 5 )
      Body.find(:all, :limit=>limit ).each_with_index do |body,i|
        company = ::Node::Company.new :name => body.name_tag
        if old_card = RootCard.find_by_tag_name( body.name_tag )
          company.revised_at = old_card.created_at
          company.content = old_card.body
          if u = ::User.find_by_name( old_card.author )
            company.created_by = u
          end
        end
        if !company.save
          warn "Body #{i}: Error creating #{body.name_tag}: COMPANY" + company.errors.plot(:join, ' ').join(';') +
            "TAG: " + company.tag.errors.plot(:join, ' ').join(';')
        else
          warn "Body #{i}: #{body.name_tag}"
        end
      end
    end
    
    def import_root_cards( limit =5 )
      RootCard.find_all_by_node_type('default', :limit=>limit).each_with_index do |old, i|
        begin
          if wiki = ::Node::Wiki.find_by_name( old.tag_name )
            wiki.tag.root_card.revise( old.body, old.created_at, get_user( old.author ))
            warn "RootCard #{i}: Updated #{old.tag_name}"
          else
            new_wiki = ::Node::Wiki.new({
              :name=> old.tag_name,
              :content => old.body,
              :revised_at => old.created_at
            })
            
            if u = get_user( old.author )
              new_wiki.created_by = u
            end
            if !new_wiki.save
              warn "RootCard #{i}: Error creating #{old.tag_name}"
              warn new_wiki.errors.plot(:join, ' ').join(';')
            else
            warn "RootCard #{i}: #{old.tag_name} by #{old.author} -> #{new_wiki.created_by.login}"
            end
          end
        rescue Exception => e
          warn "RootCard #{i}: Exception #{e.class}: #{e.message}"
        end
      end
    end
    
    def import_tag_cards( limit =5 )
      TagCard.find(:all, :limit=>limit).each_with_index do |old, i|
        if card = ::Card.find_by_name( old.card_name )
          if user = get_user( old.author )
            begin
              card.add_tag( old.tag_name, old.body, old.created_at, user )
              warn "TagCard #{i}: #{old.card_name} #{old.tag_name} by #{old.author} -> #{user.login}"
            rescue Exception=>e
              warn "TagCard #{i}: raised #{e.class}: #{e.message}"
            end
          else
            warn "#{i} couldn't find user #{old.author}"
          end
        else
          warn "#{i} couldn't find card #{old.card_name}"
        end
      end
    end
    
    def get_user( tag_name )
      old = User.find_by_name_tag tag_name 
      new = ::User.find_by_login old.login
    end
    
  end
end
