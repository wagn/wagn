# -*- encoding : utf-8 -*-
FORMATS = 'html|json|xml|rss|kml|css|txt|text|csv' unless defined? FORMATS

Wagn::Application.routes.draw do

  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end

  # these file requests should only get here if the file isn't present.
  # if we get a request for a file we don't have, don't waste any time on it.
  #FAST 404s
  match ':asset/:foo' => 'application#fast_404', :constraints =>
    { :asset=>/assets|images?|stylesheets?|javascripts?/, :foo => /.*/ }

  match '/' => 'card#read'
  match 'recent(.:format)' => 'card#read', :id => '*recent', :view => 'content'
  match '(/wagn)/:id(.:format)' => 'card#read'
  match 'files/:id(-:size)-:rev.:format' => 'card#read', :constraints => { :id=>/[^-]+/ }
  

  match 'new/:type' => 'card#read', :view => 'new'

  match 'card/:view(/:id(.:format))' => 'card#read', :constraints =>
    { :view=> /new|changes|options|related|edit/ }

  match ':controller/:action(/:id(.:format))'
  match ':action(/:id(.:format))' =>'card'
  

  match '*id' => 'card#read', :view => 'bad_address'

end




