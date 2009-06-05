# set schema for multihost wagns   (make sure this is AFTER loading wagn.rb duh)             
#ActiveRecord::Base.logger.info("------- multihost = #{System.multihost} and WAGN_NAME= #{ENV['WAGN']} -------")
if System.multihost and ENV['WAGN']    
  if mapping = MultihostMapping.find_by_wagn_name(ENV['WAGN'])
    System.base_url = "http://" + mapping.canonical_host
    System.wagn_name = mapping.wagn_name
  end
  ActiveRecord::Base.connection.schema_search_path = ENV['WAGN']
  CachedCard.set_cache_prefix "#{System.host}/#{RAILS_ENV}" 
end  
