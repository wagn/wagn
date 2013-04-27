# -*- encoding : utf-8 -*-
FORMATS = 'html|json|xml|rss|kml|css|txt|text|csv' unless defined? FORMATS #should be set by renderers

Wagn::Application.routes.draw do

  if !Rails.env.production? && Object.const_defined?( :JasmineRails )
    mount Object.const_get(:JasmineRails).const_get(:Engine) => "/specs"
  end
  
  root :to=>'card#read',   :via=>:get
  root :to=>'card#create', :via=>:post
  root :to=>'card#update', :via=>:put
  root :to=>'card#delete', :via=>:delete

  match 'files/:id(-:size)-:rev.:format' => 'card#read', :via=>:get, :constraints => { :id=>/[^-]+/ }
  match 'recent(.:format)'               => 'card#read', :via=>:get, :id => '*recent' #obviate by renaming "*recent"
  
  match '(/wagn)/:id(.:format)'          => 'card#read',   :via=>:get  #/wagn is deprecated
  match         ':id(.:format)'          => 'card#create', :via=>:post
  match         ':id(.:format)'          => 'card#update', :via=>:put
  match         ':id(.:format)'          => 'card#delete', :via=>:delete
                                         
  match 'new/:type'                      => 'card#read', :view=>'new'
  match 'card/:view(/:id(.:format))'     => 'card#read', :constraints => { :view=> /new|changes|options|edit/ }  #deprecate

  match ':controller/:action(/:id(.:format))'
  match ':action(/:id(.:format))'        => 'card'

  match '*id' => 'card#read', :view => 'bad_address'

end




