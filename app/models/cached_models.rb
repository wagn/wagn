module CachedModel
  class Base
    include Cacheable
    attr_accessor :key

    def self.type
      self.to_s.gsub(/^Cached/,'')
    end
    
    def initialize(key)
      @key=key
    end
    
    def object_key
      self.type + ":" + @key
    end
  end
end

class CachedPage < CachedModel::Base
  cache_accessor :content
end

class CachedView < CachedModel::Base
  cache_accessor :content
end

class GlobalSerial < CachedModel::Base
  include Singleton      
  
  def self.bump_dependants
    self.instance.bump_dependants
  end  
                   
  def initalize()
    @key=""
  end
end

### FILTERS
class TypeFilter < CachedModel::Base
  class << self
    def bump_dependants_for(card)
      CachedTypeFilter.new(self.type).bump_dependants
    end
  end
end

class NameFilter < CachedModel::Base 
  class << self
    def create(key)
      f = self.new(key); f.save; f
    end 
    
    def find_all
      Cache.read_list("NameFilterList").map do |f_key|
        type, key = f_key.split(':')
        Object.const_get("Cached#{type}").new(key)
      end
    end
    
    def bump_dependants_for(card)
      CachedNameFilter.find_all.each do |f|
        f.bump_dependants if f.match(card)
      end
    end
  end  
  
  def match(card)
    card.name =~ /#{self.key}/
  end

  def save
    Cache.add_to_uniq_list "NameFilterList", self.object_key
  end
end

