FORMATS = "html|json|xml|rss|kml|css|txt|text" unless defined? FORMATS
FORMAT_PATTERN = /#{FORMATS}/ unless defined? FORMAT_PATTERN   

# This regexp solves issues with cards with periods in the name.  Also makes it so you don't have to write separate routes for
#ID_REQS = { :id => /([^\.]*(\.(?!(#{FORMATS})))?)*/, :format=>FORMAT_PATTERN }
ID_REQS = { :format=>FORMAT_PATTERN }


Wagn::Application.routes.draw do
  
  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end


  constraints(ID_REQS) do

    match 'rest/:id(.:format)' => 'rest_card#method', :constraints => { :id => /.*/ }, :via => [:get, :post, :put, :delete]
    # these file requests should only get here if the file isn't present.
    # if we get a request for a file we don't have, don't waste any time on it.
    #FAST 404s
    match 'images/:foo(.:format)(/:bar)' => 'application#render_fast_404'
    match 'image/:foo.:format' => 'application#render_fast_404'
    match 'file/:foo.:format' => 'application#render_fast_404'

    match 'wagn/:id(.:format)' => 'card#show'

    match 'recent(.:format)' => 'card#show', :id => '*recent', :view => 'core'
    match 'search/:_keyword(.:format)' => 'card#show', :id => '*search', :view => 'content', 
      :constraints => { :_keyword => /([^\.]*(\.(?!(#{FORMATS})))?)*/ }
  
    match 'new/:type' => 'card#new'
    match 'me' => 'card#mine'

    match ':controller/:action(/:id(.:format)(/:attribute))'
    match ':controller(/:action)' => '#index'

    match '/' => 'card#index'

    match ':id(.:format)' => 'card#show'#, :constraints => ID_REQS
  end

  match '*id' => 'application#render_404'

end



           
