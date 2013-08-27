# -*- encoding : utf-8 -*-
FORMATS = 'html|json|xml|rss|kml|css|txt|text|csv' unless defined? FORMATS #should be set by formats

Wagn::Application.routes.draw do

  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end
  
  #most common
  root                               :to => 'card#read', :via=>:get
  match 'files/:id(-:size)-:rev.:format' => 'card#read', :via=>:get, :id => /[^-]+/, :explicit_link=>true
  match 'recent(.:format)'               => 'card#read', :via=>:get, :id => '*recent' #obviate by making links use codename
#  match ':view:(:id(.:format))'          => 'card#read', :via=>:get  
  match '(/wagn)/:id(.:format)'          => 'card#read', :via=>:get  #/wagn is deprecated
  
  # RESTful
  root              :to => 'card#create', :via=>:post
  root              :to => 'card#update', :via=>:put
  root              :to => 'card#delete', :via=>:delete
  
  match ':id(.:format)' => 'card#create', :via=>:post
  match ':id(.:format)' => 'card#update', :via=>:put
  match ':id(.:format)' => 'card#delete', :via=>:delete

  # legacy                                         
  match 'new/:type'                      => 'card#read', :view=>'new'
  match 'card/:view(/:id(.:format))'     => 'card#read', :view=> /new|options|edit/
  
  
  # standard non-RESTful
  match ':controller/:action(/:id(.:format))'
  match ':action(/:id(.:format))'        => 'card' 

  # other
  match '*id' => 'card#read', :view => 'bad_address'

end




