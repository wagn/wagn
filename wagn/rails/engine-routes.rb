# -*- encoding : utf-8 -*-

Decko::Engine.routes.draw do
  # most common
  root "card#read"
  get "#{Decko::Engine.config.files_web_path}/:id/:rev_id(-:size).:format" =>
                                 "card#read", id: /[^-]+/, rev_id: /[^-]+/, explicit_file: true
  get "#{Decko::Engine.config.files_web_path}/:id(-:size)-:rev_id.:format" =>
                                 "card#read", id: /[^-]+/, explicit_file: true  # deprecated
  get "assets/*filename"      => "card#asset"
  get "javascripts/*filename" => "card#asset"
  get "jasmine/*filename"     => "card#asset"

  get "recent(.:format)"      => "card#read", id: ":recent" # obviate by making links use codename
  #  match ':view:(:id(.:format))'          => 'card#read', via: :get
  get "(/wagn)/:id(.:format)" => "card#read"  # /wagn is deprecated

  # RESTful
  post   "/" => "card#create"
  put    "/" => "card#update"
  delete "/" => "card#delete"

  match ":id(.:format)" => "card#create", via: :post
  match ":id(.:format)" => "card#update", via: :put
  match ":id(.:format)" => "card#delete", via: :delete

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~
  # legacy
  get "new/:type"                  => "card#read",   view: "new"
  get "card/:view(/:id(.:format))" => "card#read",   view: /new|options|edit/

  get "account/signin"             => "card#read",   id: ":signin"
  get "account/signout"            => "card#delete", id: ":signin"
  get "account/signup"             => "card#read",   view: "new",  card: { type_code: :signup }
  get "account/invite"             => "card#read",   view: "new",  card: { type_code: :signup }
  get "account/accept"             => "card#read",   view: "edit", card: { type_code: :signup }
  # use type_code rather than id because in some cases (eg populating test data) routes must get loaded without loading Card

  get "admin/stats"                => "card#read",   id: ":stats"
  get "admin/:task"                => "card#update", id: ":all"
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~

  # standard non-RESTful
  get "(card)/:action(/:id(.:format))"  => "card", action: /create|read|update|delete|asset/
  match "(card)/create(/:id(.:format))" => "card#create", via: [:post, :patch]
  match "(card)/update(/:id(.:format))" => "card#update", via: [:post, :put, :patch]
  match "(card)/delete(/:id(.:format))" => "card#delete", via: :delete
  # other
  get "*id" => "card#read", view: "bad_address"
end
