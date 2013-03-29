
module Wagn
  module Set::Type::SearchType
    include Sets

    format :base

    define_view :core, :type=>:search_type do |args|
      set_search_vars args

      case
      when @error
        Rails.logger.debug " no result? #{@error.backtrace}"
        %{No results? #{@error.class.to_s} :: #{@error && @error.message} :: #{card.content}}
      when @search_spec[:return] =='count'
        @results.to_s
      else
        _render_card_list args
      end
    end

    define_view :card_list, :type=>:search_type do |args|
      @itemview ||= :name

      if @results.empty?
        'no results'
      else
        @results.map do |c|
          process_inclusion c, :view=>@itemview
        end.join "\n"
      end
    end

    format :html
    
    define_view :card_list, :type=>:search_type do |args|
      @itemview ||= :closed

      paging = _optional_render :paging, args

      _render_search_header +
      if @results.empty?
        %{<div class="search-no-results"></div>}
      else
        %{
          #{paging}
          <div class="search-result-list">
            #{
              @results.map do |c|
                %{
                  <div class="search-result-item item-#{ @itemview }">
                    #{ process_inclusion c, :view=>@itemview, :size=>args[:size] }
                  </div>
                }
              end.join
            }
          </div>
          #{ paging if @results.length > 10 }
        }
      end
    end


    define_view :closed_content, :type=>:search_type do |args|
      if @depth > 2
        "..."
      else
        search_params[:limit] = 10 #not quite right, but prevents massive invisible lists.  
        # really needs to be a hard high limit but allow for lower ones.

        set_search_vars args        
        @itemview = :link unless @itemview == :name  #FIXME - probably want other way to specify closed_view ok...
        
        _render_core args.merge( :hide=>:paging )
      end
    end

    define_view :editor, :type=>:search_type do |args|
      form.text_area :content, :rows=>10
    end

    define_view :search_header do |args|
      ''
    end

    define_view :search_header, :name=>:search do |args|
      return '' unless vars = search_params[:vars] and keyword = vars[:keyword]
      %{<h1 class="page-header search-result-header">Search results for: <em>#{keyword}</em></h1>}
    end

    define_view :card_list, :name=>:recent do |args|
      @itemview ||= :change

      cards_by_day = Hash.new { |h, day| h[day] = [] }
      @results.each do |card|
        begin
          stamp = card.updated_at
          day = Date.new(stamp.year, stamp.month, stamp.day)
        rescue Exception=>e
          day = Date.today
          card.content = "(error getting date)"
        end
        cards_by_day[day] << card
      end

      paging = _optional_render :paging, args

%{<h1 class="page-header">Recent Changes</h1>
<div class="card-frame recent-changes">
      <div class="card-body">
        #{ paging }
      } +
          cards_by_day.keys.sort.reverse.map do |day|

%{  <h2>#{format_date(day, include_time = false) }</h2>
        <div class="search-result-list">} +
             cards_by_day[day].map do |card| %{
          <div class="search-result-item item-#{ @itemview }">
               #{process_inclusion(card, :view=>@itemview) }
          </div>}
             end.join(' ') + %{
        </div>
        } end.join("\n") + %{
          #{ paging }
      </div>
</div>
}
    end



    define_view :paging, :type=>:search_type do |args|
      s = card.spec search_params
      offset, limit = s[:offset].to_i, s[:limit].to_i
      return '' if limit < 1
      return '' if offset==0 && limit > offset + @results.length #avoid query if we know there aren't enough results to warrant paging
      total = card.count search_params
      return '' if limit >= total # should only happen if limit exactly equals the total

      @paging_path_args = { :limit => limit, :item  => @itemview }
      @paging_limit = limit

      s[:vars].each { |key, value| @paging_path_args["_#{key}"] = value }

      out = ['<span class="paging">' ]

      total_pages  = ((total-1) / limit).to_i
      current_page = ( offset   / limit).to_i # should already be integer
      window = 2 # should be configurable
      window_min = current_page - window
      window_max = current_page + window

      if current_page > 0
        out << page_link( '&laquo; prev', current_page - 1 )
      end

      out << %{<span class="paging-numbers">}
      if window_min > 0
        out << page_link( 1, 0 )
        out << '...' if window_min > 1
      end

      (window_min .. window_max).each do |page|
        next if page < 0 or page > total_pages
        text = page + 1
        out <<  ( page==current_page ? text : page_link( text, page ) )
      end

      if total_pages > window_max
        out << '...' if total_pages > window_max + 1
        out << page_link( total_pages + 1, total_pages )
      end
      out << %{</span>}

      if current_page < total_pages
        out << page_link( 'next &raquo;', current_page + 1 )
      end

      out << %{<span class="search-count">(#{total})</span></span>}
      out.join
    end


    format :json

    define_view :card_list, :type=>:search_type do |args|
      @itemview ||= :name

      if @results.empty?
        'no results'
      else
        # simpler version gives [{'card':{the card stuff}, {'card' ...} vs.
        # @results.map do |c|  process_inclusion c, :view=>@itemview end
        # This which converts to {'cards':[{the card suff}, {another card stuff} ...]} we may want to support both ...
        {:cards => @results.map do |c|
            inc = process_inclusion c, :view=>@itemview
            (!(String===inc) and inc.has_key?(:card)) ? inc[:card] : inc
          end
        }
      end
    end


    module Model
      def collection?
        true
      end

      def item_cards params={}
        s = spec(params)
        raise("OH NO.. no limit") unless s[:limit]
        # forces explicit limiting
        # can be 0 or less to force no limit
        #Rails.logger.debug "search item_cards #{params.inspect}"
        Card.search( s )
      end

      def item_names params={}
        ## FIXME - this should just alter the spec to have it return name rather than instantiating all the cards!!
        ## (but need to handle prepend/append)
        #Rails.logger.debug "search item_names #{params.inspect}"
        Card.search(spec(params)).map(&:cardname)
      end

      def item_type
        spec[:type]
      end

      def count params={}
        Card.count_by_wql spec( params )
      end

      def spec params={}
        @spec ||= {}
        @spec[params.to_s] ||= get_spec(params.clone)
      end

      def get_spec params={}
        spec = Account.as_bot do ## why is this a wagn_bot thing?  can't deny search content??
          spec_content = params.delete(:spec) || raw_content
          #warn "get_spec #{name}, #{spec_content}, #{params.inspect}"
          raise("Error in card '#{self.name}':can't run search with empty content") if spec_content.empty?
          JSON.parse( spec_content )
        end
        spec.symbolize_keys!.merge! params.symbolize_keys
        if default_limit = spec.delete(:default_limit) and !spec[:limit]
          spec[:limit] = default_limit
        end
        spec[:context] ||= (cardname.junction? ? cardname.left_name : cardname)
        spec
      end
    end
  end

  class Renderer
    def set_search_vars args
      @search_vars_set ||= begin
        @search_spec = card.spec search_params
        @itemview = args[:item] || @search_spec[:view]
        @results  = card.item_cards search_params
      rescue Exception=>e
        @error = e; nil
      end
    end

    def search_params
      @search_params ||= begin
        p = self.respond_to?(:paging_params) ? paging_params : { :default_limit=> 100 }
        p[:vars] = {}
        if self == @root
          params.each do |key,val|
            case key.to_s
            when '_wql'      ;  p.merge! val
            when /^\_(\w+)$/ ;  p[:vars][$1.to_sym] = val
            end
          end
        end
        p
      end
    end
  end
  
  class Renderer::Html
    
    def page_link text, page
      @paging_path_args[:offset] = page * @paging_limit
      " #{link_to raw(text), path(@paging_path_args), :class=>'card-paging-link slotter', :remote => true} "
    end

    def paging_params
      if ajax_call? && @depth > 0
        {:default_limit=>20}  #important that paging calls not pass variables to included searches
      else
        @paging_params ||= begin
          s = {}
          [:offset,:vars].each{ |key| s[key] = params[key] }
          s[:offset] = s[:offset] ? s[:offset].to_i : 0
          if params[:limit]
            s[:limit] = params[:limit].to_i
          else
            s[:default_limit] = 20 #can be overridden by card value
          end
          s
        end
      end
    end
  end
  

end
