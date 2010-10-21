FORMATS = "html|json|xml|rss|kml" unless defined? FORMATS
FORMAT_PATTERN = /#{FORMATS}/ unless defined? FORMAT_PATTERN   

# This regexp solves issues with cards with periods in the name.  Also makes it so you don't have to write separate routes for
ID_REQS = { :id => /([^\.]*(\.(?!(#{FORMATS})))?)*/, :format=>FORMAT_PATTERN }

ActionController::Routing::Routes.draw do |map|

  # these file requests should only get here if the file isn't present.
  # if we get a request for a file we don't have, don't waste any time on it.
  #FAST 404s
  map.connect 'images/:foo.:format', :controller=>'application', :action=>'render_fast_404'
  map.connect 'image/:foo.:format', :controller=>'application', :action=>'render_fast_404'
  map.connect 'file/:foo.:format', :controller=>'application', :action=>'render_fast_404'
  map.connect 'images/:foo/:bar', :requirements=>{ :bar=>/.*/ }, :controller=>'application', :action=>'render_fast_404'
  
  map.connect 'wagn/:id.:format', :controller => 'card', :action=>'show', :requirements=> ID_REQS

  map.connect 'recent',           :controller => 'card', :action=>'show', :id=>'*recent_changes', :view=>'content'
  map.connect 'recent.:format',   :controller => 'card', :action=>'show', :id=>'*recent_changes', :view=>'content', :format=>FORMAT_PATTERN
  map.connect 'search/:_keyword.:format',           :requirements=>{ :_keyword => /([^\.]*(\.(?!(#{FORMATS})))?)*/, :format=>FORMAT_PATTERN },
                                  :controller => 'card', :action=>'show', :id=>'*search', :view=>'content'   
  map.connect 'new/:type',        :controller => 'card', :action=>'new'
  map.connect 'me',               :controller => 'card', :action=>'mine'

  map.resource :card_images
  map.resource :card_files
 
  map.connect ':controller/:action/:id/:attribute' 
  map.connect ':controller/:action/:id.:format',  :requirements=>ID_REQS
  map.connect ':controller/:action.:format', :format=>FORMAT_PATTERN  
  map.connect ':controller/:action'            
  map.connect ':controller', :action=>'index'
  map.connect '', :controller=>'card', :action=>'index'
  
  map.connect ':id.:format', :controller=> 'card', :action=>'show', :requirements=>ID_REQS
  map.connect '*id', :controller=>'application', :action=>'render_404'
 
 
end
                     
