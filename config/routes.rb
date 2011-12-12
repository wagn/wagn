FORMATS = 'html|json|xml|rss|kml|css|txt|text' unless defined? FORMATS
FORMAT_PATTERN = /#{FORMATS}/ unless defined? FORMAT_PATTERN

Wagn::Application.routes.draw do

  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end

  map.devise_for :accounts


  REST_METHODS = [:get, :post, :put, :delete]

  map.connect 'rest/:id.:format', :conditions => { :method => REST_METHODS }, :controller=>'rest_card', :requirements=>{ :id=>/.*/}, :action=> 'method'
  #map.connect_resource :rest_card

  #match 'rest/:id(.:format)' => 'rest_card#method', :constraints => { :id => /.*/ }, :via => [:get, :post, :put, :delete]
  # these file requests should only get here if the file isn't present.
  # if we get a request for a file we don't have, don't waste any time on it.
  #FAST 404s
  match ':asset/:foo' => 'application#render_fast_404', :constraints =>
    { :asset=>/assets|images?|stylesheets?|javascripts?/, :foo => /.*/ }

  match 'wagn/:id(.:format)' => 'card#show', :format => FORMAT_PATTERN

  match 'recent(.:format)' => 'card#show', :id => '*recent', :view => 'core', :format => FORMAT_PATTERN
#  match 'search/:_keyword(.:format)' => 'card#show', :id => '*search', :view => 'content', :format => FORMAT_PATTERN

  match 'new/:type' => 'card#new'

  match ':controller/:action(/:id(.:format)(/:attribute))', :format => FORMAT_PATTERN
  match ':controller(/:action)' => '#index'

  match '/' => 'card#index'

  match ':id(.:format)' => 'card#show'#, :format => FORMAT_PATTERN
  match '/files/(*id)' => 'card#show_file'
  match '*id' => 'application#render_404'

end




