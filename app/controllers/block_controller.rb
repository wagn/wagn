class BlockController < ApplicationController
  helper :wagn, :card
  
  before_filter :load_cards_from_params
                 
  def recent; 
    @title = 'Recent Changes'  
  end
  def search; 
    @title = %{Search results for "#{params[:keyword]}"}
  end
     
  def render_list( render_args )   
    # FIXME: layout=>ajax_or_not doesn't seem to work here, although it does everywhere else-- wtf?
    #  need it for looking at search results on their own page. 
    render_args[:locals].merge!( :cards=>@cards, :duplicates=>@duplicates )
    render_args.merge! :layout=>ajax_or_not
    respond_to do |format|    
      format.html { render render_args }
      format.json { render_args[:locals][:context] = "sidebar"; render_jsonp render_args }
    end
  end
  
  def recent_list
    render_list :partial=>'block/recent_changes', :locals=>{
      :context=>"searchresult", 
      :title=>"Recent Changes",
    } 
  end

  def search_list
    render_list :partial=>'block/card_list', :locals=>{
      :context => "searchresult", 
      :title=>%{Search results for "#{params[:keyword]}"}
    }
  end

=begin
  def connection_list
    query = params[:query] ? params[:query].to_sym : nil
    @button_permission = case #might later have this return the actual button
      when ([:plus_cards, :plussed_cards].member? query)
        Card::Basic.ok? :create
      when query == :cardtype_cards
         @card.me_type.ok? :create
      end
    render_list :partial=>'block/card_list', :locals => {
      :context => 'connections'
    }                                     
  end  
=end 

  
  def link_list
    render_list :partial=>'block/link_list', :locals=>{
      :card => @card
    }
  end  
  
  protected
  def requesting_javascript?
    false
  end
  
end
