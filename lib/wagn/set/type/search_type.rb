
module Wagn
  module Set
    module Type
      module SearchType
        include Sets

        format :base

        define_view :core, :type=>:search_type do |args|
          error=nil
          results = begin
            card.item_cards( search_params )
          rescue Exception=>e
            error = e; nil
          end

          case
          when results.nil?
            Rails.logger.debug error.backtrace
            %{No results? #{error.class.to_s}: #{error&&error.message}<br/>#{card.content}}
          when card.spec[:return] =='count'
            results.to_s
          else
            _render_card_list args.merge( :results=>results )
          end
        end

        define_view :card_list, :type=>:search_type do |args|
          @item_view ||= card.spec[:view] || :name

          if args[:results].empty?
            'no results'
          else
            args[:results].map do |c|
              process_inclusion c, :view=>@item_view
            end.join "\n"
          end
        end

        format :html

        define_view :editor, :type=>:search_type do |args|
          form.text_area :content, :rows=>10
        end

        define_view :closed_content, :type=>:search_type do |args|
          return "..." if @depth > 2
          results= begin
            card.item_cards( search_params )
          rescue Exception=>e
            error = e; nil
          end

          if results.nil?
            %{"#{error.class.to_s}: #{error.message}"<br/>#{card.content}}
          elsif card.spec[:return] =='count'
            results.to_s
          elsif results.length==0
            '<span class="search-count">(0)</span>'
          else
            %{<span class="search-count">(#{ card.count })</span>
            <div class="search-result-list">
              #{results.map do |c|
                %{<div class="search-result-item">#{@item_view == 'name' ? c.name : link_to_page( c.name ) }</div>}
              end*"\n"}
            </div>}
          end
        end

        define_view :card_list, :type=>:search_type do |args|
          @item_view ||= (card.spec[:view]) || :closed
          @item_size ||= (card.spec[:size]) || nil

          paging = _optional_render :paging, args

          _render_search_header +
          if args[:results].empty?
            %{<div class="search-no-results"></div>}
          else
            %{
            #{paging}
            <div class="search-result-list"> #{
            args[:results].map do |c|
              %{<div class="search-result-item item-#{ @item_view }">
                #{ process_inclusion c, :view=>@item_view, :size=>@item_size }
              </div>}
            end.join }
            </div>
            #{ paging if args[:results].length > 10 }
            }
          end
        end

        define_view :search_header do |args|
          ''
        end

        define_view :search_header, :name=>:search do |args|
          return '' unless vars = search_params[:vars] and keyword = vars[:keyword]
          %{<h1 class="page-header search-result-header">Search results for: <em>#{keyword}</em></h1>}
        end

        define_view :card_list, :name=>:recent do |args|
          cards = args[:results]
          @item_view ||= (card.spec[:view]) || :change

          cards_by_day = Hash.new { |h, day| h[day] = [] }
          cards.each do |card|
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
          <div class="search-result-item item-#{ @item_view }">
               #{process_inclusion(card, :view=>@item_view) }
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
          return '' if offset==0 && limit > offset + args[:results].length #avoid query if we know there aren't enough results to warrant paging
          total = card.count search_params
          return '' if limit >= total # should only happen if limit exactly equals the total

          @paging_path_args = { :limit => limit, :item  => ( @item_view || args[:item] ) }
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
    end
  end

  class Renderer::Html < Renderer
    def page_link text, page
      @paging_path_args[:offset] = page * @paging_limit
      " #{link_to raw(text), path(:read, @paging_path_args), :class=>'card-paging-link slotter', :remote => true} "
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
