# -*- encoding : utf-8 -*-
FORMATS = 'html|json|xml|rss|kml|css|txt|text|csv' unless defined? FORMATS

Wagn::Application.routes.draw do

  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end

  match '/' => 'card#read'
  match 'recent(.:format)' => 'card#read', :id => '*recent'
  match '(/wagn)/:id(.:format)' => 'card#read'
  match 'files/:id(-:size)-:rev.:format' => 'card#read', :constraints => { :id=>/[^-]+/ }
  

  match 'new/:type' => 'card#read', :view => 'new'

  match 'card/:view(/:id(.:format))' => 'card#read', :constraints => { :view=> /new|changes|options|edit/ }

  match ':controller/:action(/:id(.:format))'
  match ':action(/:id(.:format))' =>'card', :constraints => { :action=> /create|read|update|delete/ }

  match '*id' => 'card#read', :view => 'bad_address'

end




