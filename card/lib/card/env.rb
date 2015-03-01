# Card::Env can differ for each request; Card.config should not

class Card
  module Env
    class << self
      def reset args={}
        @@env = { :main_name => nil }
        
        if c = args[:controller]
          self[:controller] = c
          self[:session]    = c.request.session
          self[:params]     = c.request.params
          self[:ip]         = c.request.remote_ip
          self[:ajax]       = c.request.xhr? || c.request.params[:simulate_xhr]
          self[:host]       = Card.config.override_host     || c.request.env['HTTP_HOST']
          self[:protocol]   = Card.config.override_protocol || c.request.protocol
        
        end
      end
    
      def [] key
        @@env[key.to_sym]
      end
    
      def []= key, value
        @@env[key.to_sym] = value
      end
      

      def params
        self[:params] ||= {}
      end
      
      def session
        self[:session] ||= {}
      end
    
      def ajax?
        self[:ajax]
      end
    
      def method_missing method_id, *args
        case args.length
        when 0 ; self[ method_id ]
        when 1 ; self[ method_id ] = args[0]
        else   ; super
        end
      end
    end
  end  
  Env.reset
end
