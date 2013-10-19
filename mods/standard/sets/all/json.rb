# -*- encoding : utf-8 -*-
format :json do

  def get_inclusion_defaults
    { :view=>:atom }
  end

  def default_item_view
    if @depth == 0 && params[:item]
      params[:item]
    else
      :core
    end
  end
  
  def default_search_params
    { :default_limit => 0 }
  end
  
  def max_depth
    params[:max_depth] || 1
  end

  view :show do |args|
    raw = render( ( args[:view] || :atom ), args )
    case
    when String === raw  ;  raw
    when params[:pretty] ;  JSON.pretty_generate raw
    else                 ;  JSON( raw )
    end
  end

  view :name_complete do |args|
    card.item_cards :complete=>params['term'], :limit=>8, :sort=>'name', :return=>'name', :context=>''
  end
  
  view :status, :tags=>:unknown_ok, :perms=>:none do |args|
    status = case
    when !card.known?       ;  :unknown
# do we want the following to prevent fishing?  of course, they can always post...        
    when !card.ok?(:read)   ;  :unknown
    when card.real?         ;  :real
    when card.virtual?      ;  :virtual
    else                    ;  :wtf
    end
    
    hash = { :key=>card.key, :url_key=>card.cardname.url_key, :status=>status }
    hash[:id] = card.id if status == :real
     
    hash
  end

  view :atom do |args|
    h = {
      :name    => card.name,
      :type    => card.type_name,
      :content => card.raw_content
    }
    unless @depth == max_depth
      h[:value] = _render default_item_view, args
    end
    if @depth==0
      {
        :url => controller.request.original_url,
        :timestamp => Time.now.to_s,
        :card => h
      }
    else
      h
    end
  end

end
