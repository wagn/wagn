class CardtypeRenderer < Renderer::Base

=begin
  def connection_cards
    #load_cards( :id=>@card.id, :query=>'cardtype_cards' )
    super
  end
=end
  
  def extra_options
    controller.render :partial=>'options/option', :locals=>{
      :name=>'',
      :label=>'', 
      :field=>link_to_remote( "Cardtype Options", 
        :url=>{ :controller=>'options', :action=>'cardtype', :id=>params[:id], 
                :params=>{:element=>params[:element]} 
              }, :update=>"#{params[:element]}-options-workspace" 
      ), 
      :help=>''
    }
  end
  
end


                                                                           
