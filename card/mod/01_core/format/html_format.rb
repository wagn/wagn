# -*- encoding : utf-8 -*-

require_dependency 'card/diff'

class Card
  Format.register :html
  class HtmlFormat < Format
    include Diff
  
    attr_accessor  :options_need_save, :start_time, :skip_autosave

    # builtin layouts allow for rescue / testing
    LAYOUTS = Loader.load_layouts.merge 'none' => '{{_main}}'
  
    # helper methods for layout view
    def get_layout_content
      Auth.as_bot do
        if requested_layout = params[:layout]
          layout_from_card_or_code requested_layout
        else
          layout_from_rule
        end
      end
    end

    def layout_from_rule
      if rule = card.rule_card(:layout) and rule.type_id==Card::PointerID and layout_name=rule.item_names.first
        layout_from_card_or_code layout_name
      end
    end

    def layout_from_card_or_code name
      layout_card = Card.fetch name.to_s, :skip_virtual=>true, :skip_modules=>true
      if layout_card and layout_card.ok? :read
        layout_card.content
      elsif hardcoded_layout = LAYOUTS[name]
        hardcoded_layout
      else
        "<h1>Unknown layout: #{name}</h1>Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
      end
    end
    
    def get_inclusion_defaults nested_card
      {:view => (nested_card.rule( :default_html_view ) || :titled) }
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
        session[:history] ||= [card_path('')]
        if session[:history]
          session[:history].shift if session[:history].size > 5
          session[:history]
        end
      end

      def save_location
        return if ajax? || !html? || !@card.known? || (@card.codename == 'signin')
        discard_locations_for @card
        @previous_location = card_path @card.cardname.url_key
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


    def main?
      if Env.ajax?
        @depth == 0 && params[:is_main]
      else
        @depth == 1 && @mainline #assumes layout includes {{_main}}
      end
    end
  end
end
