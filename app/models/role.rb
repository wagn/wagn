class Role < ActiveRecord::Base
  acts_as_card_extension
  has_and_belongs_to_many :users
  def self.anonymous_user
    @@anonymous_user ||= User.new(:login=>'anonymous')  
  end
    
  class << self
    def cache
      @@cache ||= {}
      @@cache[System.wagn_name] ||= {}
    end
    
    def reset_cache
      @@cache ||= {}
      @@cache[System.wagn_name] = {}
    end
    
    def find_configurables
      @roles = Role.find :all, :conditions=>"codename <> 'admin'"
    end  
    
    def [](key)
      self.cache[key.to_s] ||= (Integer===key ? Role.find(key) : Role.find_by_codename(key.to_s))
    end
  end
    
  alias_method :users_without_special_roles, :users
  def users_with_special_roles
    if codename=='auth'
      User.active_users
    elsif codename=='anon'
      User.active_users + [self.class.anonymous_user]
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
  
  def anonymous?
    codename == 'anon'
  end
  

end
