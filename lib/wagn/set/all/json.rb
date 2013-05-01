# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::Json
    include Sets

    format :json

    define_view :show do |args|
      args[:item] = params[:item]
      raw = render( ( args[:view] || :atom ), args )
      case
      when String === raw  ;  raw
      when params[:pretty] ;  JSON.pretty_generate raw
      else                 ;  JSON( raw )
      end
    end

    define_view :name_complete do |args|
      card.item_cards :complete=>params['term'], :limit=>8, :sort=>'name', :return=>'name', :context=>''
    end
    
    define_view :status, :tags=>:unknown_ok, :perms=>:none do |args|
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
  end
end
