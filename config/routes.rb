FORMAT_PATTERN = /html|json/

ActionController::Routing::Routes.draw do |map|
  #map.connect 'c/:controller/:action/:id'
  #map.connect 'c/:controller/:action'
  #map.connect 'c/:controller', :action=>'index'
  
  map.connect 'wagn/:id.:format', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/, :format=>FORMAT_PATTERN }
  map.connect 'wagn/:id', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/}

  #DEPRECATED
  map.connect 'wiki/:id.:format', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/, :format=>FORMAT_PATTERN }
  map.connect 'wiki/:id', :controller => 'card', :action=>'show', :requirements=>{ :id=>/.*/}

  map.connect 'recent', :controller => 'block', :action=>'recent'

  map.connect ':controller/:action/:id/:attribute' 

  #map.connect '/card/new/:cardtype', :controller=>'card', :action=>'new'
  
  map.connect ':controller/:action/:id.:format',  :requirements=>{ :id=>/.*/, :format=>FORMAT_PATTERN  }
  map.connect ':controller/:action/:id',  :requirements=>{ :id=>/.*/ }

  map.connect ':controller/:action.:format', :requirements=>{ :format=>FORMAT_PATTERN  }
  map.connect ':controller/:action'          
  
  map.connect ':controller', :action=>'index'
  
  map.connect '', :controller=>'card', :action=>'index'
  map.connect '*id', :controller=>'application', :action=>'render_404'
  
end
                     
