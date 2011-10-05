FORMATS = "html|json|xml|rss|kml|css|txt|text" unless defined? FORMATS
FORMAT_PATTERN = /#{FORMATS}/ unless defined? FORMAT_PATTERN   

# This regexp solves issues with cards with periods in the name.  Also makes it so you don't have to write separate routes for
ID_REQS = { :id => /([^\.]*(\.(?!(#{FORMATS})))?)*/, :format=>FORMAT_PATTERN }


Wagn::Application.routes.draw do
  match 'rest/:id.:format' => 'rest_card#method', :constraints => { :id => /.*/ }, :via => [:get, :post, :put, :delete]
  # these file requests should only get here if the file isn't present.
  # if we get a request for a file we don't have, don't waste any time on it.
  #FAST 404s
  match 'images/:foo.:format' => 'application#render_fast_404'
  match 'image/:foo.:format' => 'application#render_fast_404'
  match 'file/:foo.:format' => 'application#render_fast_404'
  match 'images/:foo/:bar' => 'application#render_fast_404', :constraints => { :bar => /.*/ }
  
  match 'wagn/:id.:format' => 'card#show', :constraints => ID_REQS
  
  match 'recent' => 'card#show', :id => '*recent', :view => 'content'
  match 'recent.:format' => 'card#show', :id => '*recent', :view => 'content', :format => FORMAT_PATTERN
  match 'search/:_keyword.:format' => 'card#show', :id => '*search', :view => 'content', 
    :constraints => { :_keyword => /([^\.]*(\.(?!(#{FORMATS})))?)*/, :format => FORMAT_PATTERN }
    
  match 'new/:type' => 'card#new'
  match 'me' => 'card#mine'
  
  resource :card_images
  resource :card_files
  
  match ':controller/:action/:id/:attribute' #=> '#index'
  match ':controller/:action/:id.:format', :constraints=> ID_REQS
  match ':controller/:action.:format', :format => FORMAT_PATTERN
  match ':controller(/:action)' => '#index'
  
# these were translated by rake rails:upgrade:routes but seemed dubious to me. attempted corrections above
#  match ':controller/:action/:id/:attribute' => '#index'
#  match '/:controller(/:action(/:id))'
#  match ':controller/:action.:format' => '#index', :format => FORMAT_PATTERN
#  match ':controller/:action' => '#index'
  
#  match ':controller' => '#index'
  match '' => 'card#index'
  
  match ':id.:format' => 'card#show', :constraints => ID_REQS
  match '*id' => 'application#render_404'
end



           
