class MultihostMapping < ActiveRecord::Base
  cattr_accessor :cache
  set_table_name 'public.multihost_mappings'
  
  class << self
    def map_from_name(wagn_name)
      names = self.cache.read('names') || self.cache.write('names', {})
      System.wagn_name = wagn_name or fail "map_from_name called without name"
      mapping = (names[wagn_name] ||= begin
        find_by_wagn_name(wagn_name)
      end)
      set_base_url(mapping) if mapping
      set_connection(wagn_name)
    end
    
    def map_from_request(request)
      hosts = self.cache.read('hosts') || self.cache.write('hosts', {})
      hosts[request.host] ||= find_by_requested_host(request.host)
      mapping=hosts[request.host] or return false
      wagn_name = System.wagn_name = mapping.wagn_name
      set_base_url(mapping)
      set_connection(wagn_name)
    end
    
    private
    
    def set_base_url(mapping)
      System.base_url = ("http://" + mapping.canonical_host).gsub(/\/$/,'')
    end
    
    def set_connection(wagn_name)
      ActiveRecord::Base.connection.schema_search_path = wagn_name
    end
  end
end

