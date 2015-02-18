# -*- encoding : utf-8 -*-

Decko::Engine.routes.draw do

  #most common
  root                      :to => 'card#read', :via=>:get
  match "#{ Decko::Engine.config.files_web_path }/:id(-:size)-:rev_id.:format" => 
                                   'card#read', :via=>:get, :id => /[^-]+/, :explicit_file=>true
  match "assets/*filename"      => 'card#asset', :via=>:get
  match "javascripts/*filename" => 'card#asset', :via=>:get
  match "jasmine/*filename"     => 'card#asset', :via=>:get
  
  
  match 'recent(.:format)'      => 'card#read', :via=>:get, :id => ':recent' #obviate by making links use codename
#  match ':view:(:id(.:format))'          => 'card#read', :via=>:get  
  match '(/wagn)/:id(.:format)' => 'card#read', :via=>:get  #/wagn is deprecated
  
  # RESTful
  root              :to => 'card#create', :via=>:post
  root              :to => 'card#update', :via=>:put
  root              :to => 'card#delete', :via=>:delete
  
  match ':id(.:format)' => 'card#create', :via=>:post
  match ':id(.:format)' => 'card#update', :via=>:put
  match ':id(.:format)' => 'card#delete', :via=>:delete

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~
  # legacy                                         
  match 'new/:type'                  => 'card#read',   :view=>'new'
  match 'card/:view(/:id(.:format))' => 'card#read',   :view=> /new|options|edit/
                                                     
  match 'account/signin'             => 'card#read',   :id=>':signin'
  match 'account/signout'            => 'card#delete', :id=>':signin'
  match 'account/signup'             => 'card#read',   :view=>'new',  :card=>{ :type_code=>:signup }
  match 'account/invite'             => 'card#read',   :view=>'new',  :card=>{ :type_code=>:signup }
  match 'account/accept'             => 'card#read',   :view=>'edit', :card=>{ :type_code=>:signup }
  # use type_code rather than id because in some cases (eg populating test data) routes must get loaded without loading Card

  match 'admin/stats'                => 'card#read',   :id=>':stats'
  match 'admin/:task'                => 'card#update', :id=>':all' 
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  # standard non-RESTful
  match '(card)/:action(/:id(.:format))' => 'card', :action => /create|read|update|delete|asset/

  # other
  match '*id' => 'card#read', :view => 'bad_address'

end
