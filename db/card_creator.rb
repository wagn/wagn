class MCard < ActiveRecord::Base
  set_table_name 'cards'
  set_inheritance_column nil
  belongs_to :tag, :class_name=>'MTag', :foreign_key=>"tag_id"
  belongs_to :extension, :polymorphic=>true    
  belongs_to :current_revision, :class_name => 'MRevision', :foreign_key=>'current_revision_id'
  has_many   :revisions, :class_name=>'MRevision', :order => 'id', :foreign_key=>'card_id', :dependent=>:destroy

  def simple?() self.trunk_id.nil? end


  def before_destroy
    self.update_attribute('current_revision_id', nil)
  end
  
  def datatype_key 
    simple? ? tag.datatype_key : tag.plus_datatype_key
  end
end

class MTag < ActiveRecord::Base
  set_table_name 'tags'
  has_one :root_card, :class_name=>'MCard', :foreign_key=>"tag_id",:conditions => "trunk_id IS NULL"
  has_many :cards, :class_name=>'MCard', :foreign_key=>"tag_id", :conditions=>"trunk_id IS NOT NULL", :dependent=>:destroy
  belongs_to :current_revision, :class_name=>'MTagRevision', :foreign_key=>'current_revision_id'
  
end

class MRevision < ActiveRecord::Base
  set_table_name 'revisions'
end

class MRole < ActiveRecord::Base
  set_table_name 'roles'
  has_and_belongs_to_many :m_users, :join_table=>'roles_users', 
    :foreign_key=>'role_id', :association_foreign_key=>'user_id'
end     

class MSetting < ActiveRecord::Base
  set_table_name 'settings'
end

class MTagRevision < ActiveRecord::Base
  set_table_name 'tag_revisions'
end

class MWeb < ActiveRecord::Base
  set_table_name 'webs'
end

class MUser < ActiveRecord::Base  
  has_one :card, :class_name=>'MCard', :as=>:extension
  set_table_name 'users'
end

class MCardtype < ActiveRecord::Base
  set_table_name 'cardtypes'
end

class MWikiReference < ActiveRecord::Base
  set_table_name 'wiki_references'
end


require_dependency "#{RAILS_ROOT}/config/sample_wagn.rb"
require_dependency "#{RAILS_ROOT}/config/wagn.rb"

module CardCreator
  def using_postgres?
    MCard.connection.class.to_s.split('::').last == 'PostgreSQLAdapter'
  end
  
  def default_user_id
    if u = MUser.find_by_login('hoozebot') or u = MUser.find_by_login('wagbot') or
      u = MUser.find_by_login('admin')
      u.id
    else
      1
    end
  end
  
  def default_web_id
    #MWeb.find(:first).id
  end
  
  def create_card( type, name, content="" )
    if card = MCard.find_by_name( name )
      if card.attributes['type'] == type
        return nil
      else
        raise "Card with name #{name} exists, but is type #{card.attributes['type']} instead of #{type}"
      end
    else
      tag  = MTag.create
      tag_revision = MTagRevision.create( 
        :name=>name, 
        :tag_id=>tag.id, 
        :created_by=>default_user_id, 
        :revised_at=>Time.now() 
      )
      tag.current_revision_id = tag_revision.id
      tag.save
                            
      card = MCard.create(
        :type=>type,
        :tag_id=>tag.id,
        :name => name
      )
      revision = MRevision.create(
        :revised_at=>Time.now(),
        :card_id=> card.id,
        :created_by=>default_user_id,
        :content=>content
      )
      card.current_revision_id=revision.id
      card.save
      card
    end
  end
  
  def create_user_card( name, login, content="" )
    if card = create_card( 'User', name, content )
      user = MUser.find_by_login( login ) or raise "No user with login #{login}"
      card.extension_type = 'User'
      card.extension_id = user.id
      card.save
      card
    end
  end
  
  def create_cardtype_card( name, content="" )
    if card = create_card( 'Cardtype', name, content )
      cardtype = MCardtype.create( :class_name=>name )
      card.extension_type = 'Cardtype'
      card.extension_id = cardtype.id
      card.save
      card
    end  
  end  
  
  def create_role_card( name, codename=nil, content="")
    if card = create_card( 'Role', name, content )
      role = MRole.create( :codename=>codename )
      card.extension_type = 'Role'
      card.extension_id = role.id
      card.save
      card
    end
  end

  def create_setting_card( name, codename=nil, content="")
    if card = create_card( 'Setting', name, content )
      setting = MSetting.create( :codename=>codename )
      card.extension_type = 'Setting'
      card.extension_id = setting.id
      card.save
      card
    end
  end
  
end

