class Card
  require "card/location"

  # Card::Env can differ for each request; Card.config should not
  module Env
    class << self
      def reset args={}
        @env = { main_name: nil }
        @serializable_attributes =
          ::Set.new [:main_name, :params, :ip, :ajax, :html, :host,
                     :protocol, :salt]
        return self unless (c = args[:controller])
        self[:controller] = c
        self[:session]    = c.request.session
        self[:params]     = c.params
        self[:ip]         = c.request.remote_ip
        self[:ajax]       = c.request.xhr? || c.request.params[:simulate_xhr]
        self[:html]       = [nil, "html"].member?(c.params[:format])
        self[:host]       = Card.config.override_host ||
                            c.request.env["HTTP_HOST"]
        self[:protocol]   = Card.config.override_protocol ||
                            c.request.protocol
        self
      end

      def [] key
        @env[key.to_sym]
      end

      def []= key, value
        @env[key.to_sym] = value
      end

      def params
        self[:params] ||= {}
      end

      def session
        self[:session] ||= {}
      end

      def success cardname=nil
        self[:success] ||= Card::Success.new(cardname, params[:success])
      end

      def localhost?
        self[:host] && self[:host] =~ /^localhost/
      end

      def ajax?
        self[:ajax]
      end

      def html?
        !self[:controller] || self[:html]
      end

      def serialize
        @env.select { |k, _v| @serializable_attributes.include?(k) }
      end

      def deserialize! data
        @env ||= {}
        @env.update data
      end

      def method_missing method_id, *args
        case args.length
        when 0 then self[method_id]
        when 1 then self[method_id] = args[0]
        else super
        end
      end
    end

    # session history helpers: we keep a history stack so that in the case of
    # card removal we can crawl back up to the last un-removed location
    module LocationHistory
      def location_history
        session[:history] ||= [Card::Location.card_path("")]
        session[:history].shift if session[:history].size > 5
        session[:history]
      end

      def save_location card
        return unless save_location?(card)
        discard_locations_for card
        session[:previous_location] =
          Card::Location.card_path card.cardname.url_key
        location_history.push previous_location
      end

      def save_location? card
        !Env.ajax? && Env.html? && card.known? && (card.codename != "signin")
      end

      def previous_location
        return unless location_history
        session[:previous_location] ||= location_history.last
      end

      def discard_locations_for card
        # quoting necessary because cards have things like "+*" in the names..
        session[:history] = location_history.reject do |loc|
          if (url_key = url_key_for_location(loc))
            url_key.to_name.key == card.key
          end
        end.compact
        session[:previous_location] = nil
      end

      def save_interrupted_action uri
        session[:interrupted_action] = uri
      end

      def interrupted_action
        session.delete :interrupted_action
      end

      def url_key_for_location location
        (%r{/([^/]*$)} =~ location) ? Regexp.last_match[1] : nil
      end
    end

    extend LocationHistory
  end

  Env.reset
end
