FORMATS = 'html|json|xml|rss|kml|css|txt|text' unless defined? FORMATS
FORMAT_PATTERN = /#{FORMATS}/ unless defined? FORMAT_PATTERN

Wagn::Application.routes.draw do

  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end

  match 'rest/:id(.:format)' => 'rest_card#method', :constraints => { :id => /.*/ }, :via => [:get, :post, :put, :delete]
  # these file requests should only get here if the file isn't present.
  # if we get a request for a file we don't have, don't waste any time on it.
  #FAST 404s
  match ':asset/:foo' => 'application#fast_404', :constraints =>
    { :asset=>/assets|images?|stylesheets?|javascripts?/, :foo => /.*/ }

#  match '(wagn/):id.:format' => 'card#show_file', :format => /jpg|jpeg|png|gif|ico/

  match '/' => 'card#index'
  match 'recent(.:format)' => 'card#show', :id => '*recent', :view => 'content'
  match '(/wagn)/:id(.:format)' => 'card#show'
  match '/files/(*id)' => 'card#show_file'

  match 'new/:type' => 'card#new'

  match ':controller/:action(/:id(.:format)(/:attribute))'


  
  match '*id' => 'application#bad_address'

end




