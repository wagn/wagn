class MultihostMapping < ActiveRecord::Base
  cattr_accessor :cache
  set_table_name 'public.multihost_mappings'
  
  class << self
    def cache=(v)
      raise "seting to hash?? #{v.inspect}" if Hash===v
      @@cache=v
    end
    def map_from_name(wagn_name)
      Wagn::Conf[:wagn_name] = wagn_name or fail "map_from_name called without name"
      mapping = (@@cache[:name][wagn_name] ||= begin
        find_by_wagn_name(wagn_name)
      end)
      set_base_url(mapping) if mapping
      set_connection(wagn_name)
    end

    def map_from_request(request)
      @@cache[:host][request.host] ||= find_by_requested_host(request.host)
      mapping=@@cache[:host][request.host] or return false
      wagn_name = Wagn::Conf[:wagn_name] = mapping.wagn_name
      set_base_url(mapping)
      set_connection(wagn_name)
    end

    def reset_cache
      @@cache = {:name=>{},:host=>{}}
    end
    
    private
    
    def set_base_url(mapping)
      Wagn::Conf[:base_url] = ("http://" + mapping.canonical_host).gsub(/\/$/,'')
    end
    
    def set_connection(wagn_name)
      ActiveRecord::Base.connection.schema_search_path = wagn_name
    end
  end
    
  reset_cache
end

