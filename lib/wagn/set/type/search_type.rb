module Wagn

  class Renderer
    def set_search_vars args
      @search ||= begin
        v = {}
        v[:spec] = card.spec search_params
        v[:item] = args[:item] || v[:spec][:view]
        v[:results]  = card.item_cards search_params
        v
      rescue Exception=>e
        { :error => e }
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
    
    private

    #hacky.  here for override
    def goto_wql(term)
     { :complete=>term, :limit=>8, :sort=>'name', :return=>'name' }
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