FORMAT_PATTERN = /html|json|xml|rss/ unless defined? FORMAT_PATTERN   

#require 'ruby-debug'
#debugger

ActionController::Routing::Routes.draw do |map|
  #map.connect 'c/:controller/:action/:id'
  #map.connect 'c/:controller/:action'
  #map.connect 'c/:controller', :action=>'index'

  REST_METHODS = [:get, :post, :put, :delete]

  map.connect 'xmlcard/:id', :conditions => { :method => REST_METHODS }, :controller=>'xmlcard', :format=>'xml', :requirements=>{ :id=>/.*/}, :action=> 'method'
  #map.connect_resource :xmlcard

  # these file requests should only get here if the file isn't present.
  # if we get a request for a file we don't have, don't waste any time on it.
  map.connect 'images/:foo.:format', :controller=>'application', :action=>'render_fast_404'
  map.connect 'image/:foo.:format', :controller=>'application', :action=>'render_fast_404'
  map.connect 'file/:foo.:format', :controller=>'application', :action=>'render_fast_404'

  map.connect 'images/:foo/:bar', :requirements=>{ :bar=>/.*/ }, :controller=>'application', :action=>'render_fast_404'
  
  map.connect 'wagn/:id.:format', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/, :format=>FORMAT_PATTERN }
  map.connect 'wagn/:id', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/}

  #DEPRECATED
  map.connect 'wiki/:id.:format', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/, :format=>FORMAT_PATTERN }
  map.connect 'wiki/:id', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/}
  #/DEPRECATED   

  map.connect 'recent',           :controller => 'card', :action=>'show', :id=>'*recent_changes', :view=>'content'
  map.connect 'recent.:format',   :controller => 'card', :action=>'show', :id=>'*recent_changes', :view=>'content', :requirements=>{ :format=>FORMAT_PATTERN }
  map.connect 'search/:_keyword.:format', :controller => 'card', :action=>'show', :id=>'*search',         :view=>'content', :requirements=>{ :format=>FORMAT_PATTERN }   
  map.connect 'search/:_keyword', :controller => 'card', :action=>'show', :id=>'*search',         :view=>'content'
  map.connect 'new/:cardtype',    :controller => 'card', :action=>'new'
  map.connect 'me',               :controller => 'card', :action=>'mine'
 
  map.connect ':controller/:action/:id/:attribute' 
  #map.connect '/card/new/:cardtype', :controller=>'card', :action=>'new'
  
  map.connect ':controller/:action/:id.:format',  :requirements=>{ :id=>/.*/, :format=>FORMAT_PATTERN  }
  map.connect ':controller/:action/:id',  :requirements=>{ :id=>/.*/ }

  map.connect ':controller/:action.:format', :requirements=>{ :format=>FORMAT_PATTERN  }
  map.connect ':controller/:action'          
  
  map.connect ':controller', :action=>'index'
  
  map.connect '', :controller=>'card', :action=>'index'
  map.connect ':id.:format', :controller=> 'card', :action=>'show', :requirements=>{ :id=>/.*/, :format=>FORMAT_PATTERN} 
  map.connect ':id', :controller=> 'card', :action=>'show', :requirements=>{ :id=>/.*/} 

  #map.connect 'xml/:controller/:id',  :format=>'xml', :requirements=>{ :id=>/.*/}, :action=> :method
  #map.resource ':card' , :plural=>'card'
  
  map.connect '*id', :controller=>'application', :action=>'render_404'
end
                     
