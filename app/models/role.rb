require_dependency "acts_as_card_extension"

class Role < ActiveRecord::Base
  acts_as_card_extension
  has_and_belongs_to_many :users
  @@anonymous_user = User.new(:login=>'anonymous')  

  alias_method :users_without_special_roles, :users
  def users_with_special_roles
    if codename=='auth'
      User.active_users
    elsif codename=='anon'
      User.active_users + [@@anonymous_user]
    else
      users_without_special_roles
    end
  end
  alias_method :users, :users_with_special_roles
  
  def task_list
    (self.tasks || '').split ","
  end
  
  def cardname
    self.card.name
  end
  
  def subset_of?( role )
    case 
    when role.codename=='anon'; true  
    when self.codename=='anon'; false 
    when role.codename=='auth'; true
    when self.codename=='auth'; false
    else ::User.find_by_sql(%{
      select * from users u1 
      join roles_users ru1 on ru1.user_id=u1.id and ru1.role_id=#{self.id} 
      left join roles_users ru2 on ru2.user_id=u1.id and ru2.role_id=#{role.id} 
      where ru2.user_id is null
    }).length == 0
    end
    #users.detect {|u| !role.users.include?(u) }.nil?
  end
  
  def subset_roles
    Role.find(:all).select{|r| r.subset_of?(self) }
  end
  
  def superset_roles
    Role.find(:all).select{|r| self.subset_of?(r) }
  end
  
  class << self
    def find_configurables
      @roles = Role.find :all, :conditions=>"codename <> 'admin'"
    end  
    
    def [](codename)
      Role.find_by_codename(codename)
    end
  end
  
  
end
