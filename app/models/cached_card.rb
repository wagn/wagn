=begin        
  cards loaded in 3 places
  
  1. initial load card()          
  2. processing transclusion()
  3. processing search()
  
=end     

class CachedCard 
  cattr_accessor :cache, :perform_caching
  attr_reader :key
  attr_accessor :comment, :comment_author
  self.cache = ActionController::Base.fragment_cache_store
  self.perform_caching = ActionController::Base.perform_caching  
  
  cattr_accessor :card_names
  self.card_names={}
  
  class << self   
    # FIXME: opts[:no_new] is an ugly hack- interface needs work. 
    def get(name, card=nil, opts={}) 
      key = name.to_key
      caching = (opts.has_key?(:cache) ? opts[:cache] : true) && perform_caching 
      card_opts = opts[:card_params] ? opts[:card_params] : {}
      card_opts['name'] = name if (name && !name.blank?)

      r = if caching && (cached_card = self.find(key, card, opts))
        ActiveRecord::Base.logger.info("<get(InCache) name=#{name}>")
        cached_card

      elsif card 
        #logger.info("<get(PassedIn) name=#{name}>")
        self.new_cached_if_cacheable(card, opts)

      elsif name.blank?
        Card.new(card_opts) unless opts[:no_new]
      
      elsif card = Card.find_builtin(name)  
        #logger.info("<get(BuiltIn) name=#{name}>")
        card 
        
      elsif name.junction? && (template = self.find( name.auto_template_name.to_key )) && template.type=='Search'
        #logger.info("<get(CachedPhantom) name=#{name}>")
        User.as(:admin){ Card.create_phantom( name, template.content ) }  # FIXME

      elsif card = Card[name] 
        #logger.info("<get(DB) name=#{name}>")
        self.new_cached_if_cacheable(card, opts)

      elsif  name.junction? && (template = Card[ name.auto_template_name ]) && template.type=='Search' 
        #logger.info("<get(Phantom) name=#{name}>")
        template = self.new_cached_if_cacheable(template, opts)
        User.as(:admin){ Card.create_phantom( name, template.content ) } # FIXME
        
      else   
        #logger.info("<get(New) name=#{name}>")
        Card.new(card_opts) unless opts[:no_new]  
      end 
      #logger.info("</get res=#{r}>")
      r
    end
    
    def new_cached_if_cacheable(card,opts={})
      caching = (opts.has_key?(:cache) ? opts[:cache] : true) && perform_caching 
      caching && card.cacheable? ? self.new( card.key, card, opts) : card
    end
    
    def find(key, card=nil, opts={})
      cached_card = self.new(key, card, opts)            
      cached_card.exists? ? cached_card : nil
    end     
  end
  
  def initialize(key, real_card=nil, opts={})
    @auto_load = opts[:auto_load_card]   
    #ActiveRecord::Base.logger.info("<Cache init: #{key}, #{real_card}>")
    @card = real_card
    @key=key
  end
  
  def exists?
    !!(read('name') || read('content'))
  end
  
  def phantom?() false end  # only cache non-phantom cards
  def new_record?() false end  # only cache existing cards
   
  def to_id() id end            
  def id()  id = get('id') { card.id.to_s }; id.to_i end
  def name()  get('name') { card.name } end
  def type()  get('type') { card.type } end 
  def content() get('content') { card.content } end
    
  def read_permission() 
    get('read_permission') { p = card.who_can(:read);  "#{p.class.to_s}:#{p.id}" }
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
      else card.ok?(task)
    end
  end
  
  def party_ok?(party_str)
    party_class, party_id = party_str.split(':'); party_id = party_id.to_i   
    party_class == 'Role' ? System.role_ok?(party_id) : (party_id==User.current_user.id)
  end

  def line_content()   read('line_content') end
  def line_content=(content)  write('line_content', content)  end      
  
  def view_content() read('view_content') end
  def view_content=(content)  write('view_content', content) end
  
  def footer() read('footer') end
  def footer=(content) write('footer', content) end
  

  def card
    @card ||= (
      ActiveRecord::Base.logger.info("<Loading: #{@key}>")
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
    %w{id name type content read_permission comment_permission line_content view_content footer }.each do |f|
      expire(f)
    end
  end 
  
  def expire(field)   
    #warn "EXPIRE /card/#{@key}/#{field}"
    self.class.cache.delete("/card/#{@key}/#{field}", nil)
  end
end        


