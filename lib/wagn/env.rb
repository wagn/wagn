# Wagn::Env can differ for each request; Wagn.config should not

module Wagn::Env
  class << self
    def reset args={}
      @@env = { :main_name => nil }
      
      if c = args[:controller]
        self[:controller] = c
        self[:params] = c.request.params
        
        self[:host]       = Wagn.config.override_host     || c.request.env['HTTP_HOST']
        self[:protocol]   = Wagn.config.override_protocol || c.request.protocol
        
        #hacky - should be in module
        self[:recaptcha_on] = !Account.logged_in? && have_recaptcha_keys?
        self[:recaptcha_count] = 0
      end
    end
    
    def [] key
      @@env[key.to_sym]
    end
    
    def []= key, value
      @@env[key.to_sym] = value
    end

    def params
      self[:params] || {}
    end
    
    private
    
    def have_recaptcha_keys?
      !!( Wagn.config.recaptcha_public_key && Wagn.config.recaptcha_private_key )
    end    
  end  
end

Wagn::Env.reset

