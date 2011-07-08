class MultihostMapping < ActiveRecord::Base
  set_table_name 'public.multihost_mappings'
  
  class << self
    def map_from_environment(wagn_name)
      System.wagn_name = wagn_name or fail "cannot map from environment without WAGN environmental variable"
      mapping = find_by_wagn_name(wagn_name) or fail "unknown wagn: #{wagn_name}"
      set_base_url(mapping)
      set_connection(wagn_name)
    end
    
    def map_from_request(request)
      mapping = find_by_requested_host(request.host) or return false
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

