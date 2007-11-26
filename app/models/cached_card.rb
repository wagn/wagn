=begin        
  cards loaded in 3 places
  
  1. initial load card()          
  2. processing transclusion()
  3. processing search()
  
=end     

class CachedCard 
  cattr_accessor :cache, :perform_caching
  attr_reader :key
  attr_accessor :comment
  self.cache = ActionController::Base.fragment_cache_store
  self.perform_caching = ActionController::Base.perform_caching  
  
  class << self   
    def get(name, card=nil, opts={}) 
      cache = opts.has_key?(:cache) ? opts[:cache] : true
      key = name.to_key
      if cache && perform_caching && (cached_card = self.find(key, opts))
        cached_card
      elsif card || (card=Card.find_by_key_and_trash(key, false))
        (cache && perform_caching && card.cacheable?) ? self.new(key, card, opts) : card
      elsif card=Card.find_phantom(name)
        card
      else   
        card_opts = opts[:card] ? opts[:card] : {}
        card_opts['name'] = name if name
        c = Card.new(card_opts)  # FIXME: set defaults?
        c.send(:set_defaults)
        c
      end  
    end
    
    def find(key, opts={})
      cached_card = self.new(key, nil, opts)            
      cached_card.exists? ? cached_card : nil
    end     
  end
  
  def initialize(key, real_card=nil, opts={})
    @auto_load = opts[:auto_load_card]
    @card = real_card
    @key=key
  end
  
  def exists?
    !!read('name')
  end
  
  def phantom?() false end  # only cache non-phantom cards
  def new_record?() false end  # only cache existing cards
   
  def to_id() id end            
  def id()  id = get('id') { card.id.to_s }; id.to_i end
  def name()  get('name') { card.name } end
  def type()  get('type') { card.type } end  
    
  def read_permission() 
    get('read_permission') { p = card.who_can(:read); "#{p.class.to_s}:#{p.id}" }
  end       
  
  def comment_permission() 
    get('comment_permission') {
       p = card.who_can(:comment); 
       p ? "#{p.class.to_s}:#{p.id}" : "User:-1"
    }
  end

  def ok?(task) 
    case task
      when :read; party_ok?(read_permission)
      when :comment; party_ok?(comment_permission)
      else  card.ok?(task)
    end
  end
  
  def party_ok?(party_str)
    party_class, party_id = party_str.split(':'); party_id = party_id.to_i   
    party_class == 'Role' ? System.role_ok?(party_id) : (party_id==User.current_user.id)
  end

  def line_content() 
    #ActiveRecord::Base.logger.info("CACHE READING line_content")
    res = read('line_content') || nil
    #ActiveRecord::Base.logger.info("CACHE READ line_content: #{res}")
    res
  end
  
  def line_content=(content)  
    write('line_content', content) 
  end      
  
  def view_content()
    #ActiveRecord::Base.logger.info("CACHE READING view_content")
    res = read('view_content') || nil
    #ActiveRecord::Base.logger.info("CACHE READ view_content: #{res}")
    res
  end
  
  def view_content=(content)
    write('view_content', content)
  end
  
  def card
    @card ||= (
      ActiveRecord::Base.logger.info("loading: #{@keu}")
      Card.find_by_key_and_trash(@key, false)
    )
  end

  def method_missing(method_id,*args)
    (@card || @auto_load) ? card.send(method_id, *args) : raise("Unknown method: #{method_id}")
  end
  
  def get(field)
    read(field) or begin
      value = yield
      write(field, value)
      value
    end
  end
  
  def read(field)
    self.class.cache.read("/card/#{@key}/#{field}")
  end
  
  def write(field, value)
    self.class.cache.write("/card/#{@key}/#{field}", value) 
  end    
  
  def expire_all  
    # FIXME: easy place for bugs if using a key that's not here.    
    # why not regexp? rails docs say:
    # Regexp expiration is not supported on caches which can‘t iterate over all keys, such as memcached.
    %w{id name type read_permission comment_permission line_content view_content }.each do |f|
      expire(f)
    end
  end 
  
  def expire(field)   
    #warn "EXPIRE /card/#{@key}/#{field}"
    self.class.cache.delete("/card/#{@key}/#{field}", nil)
  end
end        


