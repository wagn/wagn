# -*- encoding : utf-8 -*-

require_dependency 'card/diff'

class Card
  Format.register :html
  class HtmlFormat < Format
    include Diff
  
    attr_accessor  :options_need_save, :start_time, :skip_autosave

    # builtin layouts allow for rescue / testing
    LAYOUTS = Loader.load_layouts.merge 'none' => '{{_main}}'

    INCLUSION_DEFAULTS = {
      :layout => { :view => :core },
      :normal => { :view => :content }
    }
  
    def get_inclusion_defaults
      INCLUSION_DEFAULTS[@mode] || {}
    end
  
    def default_item_view
      :closed
    end

    def output content
      case content
      when String; content
      when Array ; content.compact.join "\n"
      end
    end  

    def html_escape_except_quotes s
      # to be used inside single quotes (makes for readable json attributes)
      s.to_s.gsub(/&/, "&amp;").gsub(/\'/, "&apos;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end
    
    #### --------------------  additional helpers ---------------- ###

    # session history helpers: we keep a history stack so that in the case of
    # card removal we can crawl back up to the last un-removed location

    module Location
      def location_history
        #warn "sess #{session.class}, #{session.object_id}"
        session[:history] ||= [wagn_path('')]
        if session[:history]
          session[:history].shift if session[:history].size > 5
          session[:history]
        end
      end

      def save_location
        return if ajax? || !html? || !@card.known? || (@card.codename == 'signin')
        discard_locations_for @card
        @previous_location = wagn_path @card.cardname.url_key
        location_history.push @previous_location
      end

      def previous_location
        @previous_location ||= location_history.last if location_history
      end

      def discard_locations_for(card)
        # quoting necessary because cards have things like "+*" in the names..
        session[:history] = location_history.reject do |loc|
          if url_key = url_key_for_location(loc)
            url_key.to_name.key == card.key
          end
        end.compact
        @previous_location = nil
      end

      def save_interrupted_action uri
        uri = path(uri) if Hash === uri
        session[:interrupted_action] = uri
      end
  
      def interrupted_action
        session.delete :interrupted_action
      end

      def url_key_for_location(location)
        location.match( /\/([^\/]*$)/ ) ? $1 : nil
      end
    end
    include Location

    def final_link href, opts={}
      text = (opts.delete(:text) || href).dup
      content_tag :a, raw(text), opts.merge(:href=>href)
    end

    def link_to_view text, view, opts={}
      path_opts = view==:home ? {} : { :view=>view }
      if p = opts.delete( :path_opts )
        path_opts.merge! p
      end
      opts[:remote] = true
      opts[:rel] = 'nofollow'
      link_to text, path( path_opts ), opts
    end

    def main?
      if Env.ajax?
        @depth == 0 && params[:is_main]
      else
        @depth == 1 && @mainline #assumes layout includes {{_main}}
      end
    end
  end
end
