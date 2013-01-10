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

  match 'recent(.:format)' => 'card#read', :id => '*recent', :view => 'content'

  resources :card, :path => '/', :except => :show
  get '/:id(.:format)' => 'card#read'

  match '(/wagn)/:id(.:format)' => 'card#read'
  match '/files/(*id)' => 'card#read_file'

  match 'new/:type' => 'card#read', :view => 'new'

  match 'card/:view(/:id(.:format)(/:attribute))' => 'card#read', :constraints =>
    { :view=> /new|changes|options|related|edit/ }

  match ':controller/:action(/:id(.:format)(/:attribute))'

  match '*id' => 'card#read', :view => 'bad_address'

end




