=begin        
  cards loaded in 3 places
  
  1. initial load card()          
  2. processing transclusion()
  3. processing search()
  
=end     

class CacheError < StandardError; end

class CachedCard 
  cattr_accessor :cache, :perform_caching
  attr_reader :key
  attr_accessor :comment, :comment_author
  self.cache = ActionController::Base.fragment_cache_store
  self.perform_caching = ActionController::Base.perform_caching  
  
  cattr_accessor :card_names
  self.card_names={}
  
  class << self       
    
    # get_real is for when you want to use the cache, but don't want any builtins, auto,
    # card_creation, or any type of shenanigans.  give me the card if it's there, otherwise nil.
    # called by templating system
    def get_real(name)  
      return Card[name] unless perform_caching
      key = name.to_key
      if card = self.find(key)
        card
      elsif card = self.load_card(name)
        self.cache_me_if_you_can(card, :cache=>true)
      end
    end
    
    def get(name, card=nil, opts={}) 
      key = name.to_key
      caching = (opts.has_key?(:cache) ? opts[:cache] : true) && perform_caching 
      card_opts = opts[:card_params] ? opts[:card_params] : {}
      card_opts['name'] = name if (name && !name.blank?)

      todo = 
        case
          when caching && (card = self.find(key, card, opts)) ; [ :got_it     , 'found in cache'   ] 
          when card                                           ; [ :cache_it   , 'called with card' ]
          when name.blank?                                    ; [ :make_it    , 'blank name'       ]
          when card = Card.find_builtin(name)                 ; [ :got_it     , 'built-in'         ]
          when card = self.load_card(name)                    ; [ :cache_it   , 'found by name'    ]
          when card = Card.auto_card(name)                    ; [ :got_it     , 'auto card'        ]
          else                                                ; [ :make_it    , 'scratch'          ]
        end 
        
      ActiveRecord::Base.logger.info "<get card: #{name} :: #{todo.last}>"

      case todo.first
        when :got_it   ;    card
        when :cache_it ;    self.cache_me_if_you_can(card, opts)       
        when :make_it  ;    Card.new(card_opts) unless opts[:no_new]    # FIXME: opts[:no_new] is an ugly hack- interface needs work.     
          
          ## opts[:no_new] is here for cases when you want to look for a card in the cache and do something else
          ## if it's not there-- particularly builtin cards such as *favicon.  If an anonymous user tries to
          ## get one of these cards, it's not there, and we try to create it, it blows up on permissions,
          ## which is a weird error to the user because they were just trying to view.
      end
    end
    
    def load_card(name)  
      cached_card = self.new(name.to_key)
      return nil if cached_card.read('missing')  
      if card = Card[name]
        card
      else
        # make a note that we didn't find it
        cached_card.write('missing','true')
        nil
      end
    end
    
    def cache_me_if_you_can(card,opts={})
      caching = (opts.has_key?(:cache) ? opts[:cache] : true) && perform_caching 
      if caching && card.cacheable? 
        cc = self.new( card.key, card, opts)
        cc.name  # trigger a write to the cache, so it will be found next time.
        cc
      else 
        card
      end
    end
    
    def find(key, card=nil, opts={})
      return false unless perform_caching
      cached_card = self.new(key, card, opts)            
      cached_card.exists? ? cached_card : nil
    end
    
    def [](name)
      find(name.to_key) || Card[name]
    end
         
  end
  
  def initialize(key, real_card=nil, opts={})
    @auto_load = opts[:auto_load_card]   
    #ActiveRecord::Base.logger.info("<Cache init: #{key}, #{real_card}>")
    @card = real_card  
    @attrs = nil 
    @key=key
  end
  
  def exists?
    !!(read('name') || read('content'))
  end
  
  def phantom?() false end  # only cache non-phantom cards -- not sure this should be the case.
  def new_record?() false end  # only cache existing cards


  # FIXME -- these methods cut and pasted from templating-- need a standard place to 
  #  mix in methods that will work with both basic cards and cached_cards
  def hard_template?
    extension_type =='HardTemplate'
  end

  def soft_template?
    extension_type =='SoftTemplate'
  end
  # /FIXME    
  
  
   
  def to_id() id end            
  def id()  id = get('id') { card.id.to_s }; id.to_i end
  def name()  get('name') { card.name } end
  def type()  get('type') { card.type } end 
  def content() get('content') { card.content } end
  def extension_type() get('extension_type') { card.extension_type } end
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
  
  def real_card
    card || begin
      expire_all
      raise(CacheError, "cached card #{@key} found but it's not in database")
    end
  end
  
  def card
    @card ||= (
      ActiveRecord::Base.logger.info("<Loading: #{@key}>")
      Card.find_by_key_and_trash(@key, false)
    )
  end

  def method_missing(method_id,*args)
    (@card || @auto_load) ? card.send(method_id, *args) : raise("Unknown method: #{method_id} for CachedCard")
  end
  
  def get(field)
    read(field) or begin
      value = yield  
      write(field, value)
      value
    end
  end
  
  def read(field)   
    #self.class.cache.read("/card/#{@key}/#{field}")      
    self.attrs[field]
  end
  
  def write(field, value)
    #self.class.cache.write("/card/#{@key}/#{field}", value) 
    self.attrs[field] = value
    self.save
  end          
  
  def attrs
    @attrs ||= begin 
      warn "retrieving #{@key}"
      if str = self.class.cache.read("/card/#{@key}/attrs")  
        Marshal.load( str )
      else
        {}
      end
    end
  end  
  
  def save
    str = Marshal.dump @attrs
    self.class.cache.write("/card/#{@key}/attrs", str)  
  end
  
  def expire_all  
    # FIXME: easy place for bugs if using a key that's not here.    
    # why not regexp? rails docs say:
    # Regexp expiration is not supported on caches which can‘t iterate over all keys, such as memcached.
    #%w{id missing extension_type name type content read_permission comment_permission line_content view_content footer }.each do |f|
    #  expire(f)
    #end
    self.class.cache.write("/card/#{@key}/attrs", nil)
    @attrs = nil
  end 
  
  def expire(field) 
    expire_all 
    #warn "EXPIRE /card/#{@key}/#{field}"
    #self.class.cache.delete("/card/#{@key}/#{field}", nil)
  end
end        


