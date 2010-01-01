=begin        
  cards loaded in 3 places
  
  1. initial load card()          
  2. processing transclusion()
  3. processing search()
  
=end     

class CacheError < StandardError; end

class CachedCard 
  cattr_accessor :cache, :perform_caching, :cache_key_prefix, :seq_key
  attr_reader :key
  attr_accessor :comment, :comment_author
  self.cache = ActionController::Base.cache_store
  self.perform_caching = ActionController::Base.perform_caching  
  
  cattr_accessor :card_names, :local_cache
  self.card_names={} 
  self.local_cache={ :real=>{}, :get=>{}, :seq=>nil }
                                           
  
  include ::Cardlib::Cacheable
  
  class << self       
    def set_cache_prefix( prefix )
      self.cache_key_prefix = prefix
      self.seq_key = self.cache_key_prefix + "/global_seq"
    end
    
    def reset_cache
      self.local_cache = {
        :real => {},
        :get => {},
        :seq => nil
      }  
    end
    
    def global_seq 
      self.local_cache[:seq] ||= (cache.read(@@seq_key) || bump_global_seq )
    end

    def bump_global_seq
      write_global_seq(  UUID.new.generate )
    end

    def write_global_seq(val)
      cache.write(@@seq_key, val.to_s) 
      val
    end

    # get_real is for when you want to use the cache, but don't want any builtins, auto,
    # card_creation, or any type of shenanigans.  give me the card if it's there, otherwise nil.
    # called by templating system
    def get_real(name)     
      key = name.to_key             
           
      return Card[name] unless perform_caching
      
      if self.local_cache[:real].has_key?(key)
        return self.local_cache[:real][key]
      else
        self.local_cache[:real][key] = begin
          if card = self.find(key)
            card
          elsif card = self.load_card(name)
            self.cache_me_if_you_can(card, :cache=>true)
          end
        end
      end
    end
    
    def get(name, card=nil, opts={})   
      key = name.to_key

      if self.local_cache[:get].has_key?(key)
        return self.local_cache[:get][key]
      else
        self.local_cache[:get][key] = begin
      
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
        
          #ActiveRecord::Base.logger.info "<get card: #{name} :: #{todo.last}>"

          case todo.first
            when :got_it   ;    card
            when :cache_it ;    self.cache_me_if_you_can(card, opts)       
            when :make_it  ;    
              Card.new(card_opts.merge(:skip_defaults=>true)) unless opts[:no_new]    # FIXME: opts[:no_new] is an ugly hack- interface needs work.     
          
              ## opts[:no_new] is here for cases when you want to look for a card in the cache and do something else
              ## if it's not there-- particularly builtin cards such as *favicon.  If an anonymous user tries to
              ## get one of these cards, it's not there, and we try to create it, it blows up on permissions,
              ## which is a weird error to the user because they were just trying to view.
          end
        end
      end
    end

    # FIXME: didn't write test because not sure how Cache testing interacts with test data
    #  potential rabbit-hole.
    def exists?(name)
      card = self.get( name ) and !card.new_record? 
    end

    def load_card(name)  
      cached_card = self.new(name.to_key)
      return nil if perform_caching && cached_card.read('missing')  
      if card = Card[name]
        card
      else
        # make a note that we didn't find it
        cached_card.write('missing','true') if perform_caching
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
  
  def virtual?() false end  # only cache non-virtual cards -- not sure this should be the case.
  def new_record?() false end  # only cache existing cards
   
  def to_id() id end            
  def id()  id = get('id') { card.id.to_s }; id.to_i end
  def name()  get('name') { card.name } end
  def type()  get('type') { card.type } end 
  def content() get('content') { card.content } end
  def extension_type() get('extension_type') { card.extension_type } end
  def created_at() get('created_at') { card.created_at } end
  def updated_at() get('updated_at') { card.updated_at } end
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
      when :read; System.always_ok? || party_ok?(read_permission)
      when :comment; party_ok?(comment_permission)
      else card && card.ok?(task)
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
      #ActiveRecord::Base.logger.info("<Loading: #{@key}>")
      Card.find_by_key_and_trash(@key, false) || raise(CacheError, "cached card #{@key} found but it's not in database")
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
    self.attrs[field]
  end
  
  def write(field, value)
    self.attrs[field] = value
    self.save
  end          
  
  def attrs
    @attrs ||= begin 
      begin 
        Marshal.load( self.class.cache.read(full_key))
      rescue Exception=>e
        {}
      end         
      
    end
  end  
  
  def save
    str = Marshal.dump @attrs
    self.class.cache.write(full_key, str)  
  end
  
  def full_key   
    "#{@@cache_key_prefix}/set-#{self.class.global_seq}/#{@key}"
  end
  
  def expire_all  
    self.class.cache.write(full_key, nil)
    # need to expire local cache as well
    self.local_cache[:real].delete(@key) if self.local_cache[:real].has_key?(@key)
    self.local_cache[:get].delete(@key) if self.local_cache[:get].has_key?(@key)      
    @attrs = nil
  end 
  
  def expire(field)  
    expire_all()  
  end
end        


