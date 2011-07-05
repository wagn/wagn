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
      Rails.logger.debug "looking up Role (#{key}) via []"  
      self.cache[key.to_s] ||= (Integer===key ? find(key) : find_by_codename(key.to_s))
    end
  end
        
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
