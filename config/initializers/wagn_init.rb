
ActionController::Dispatcher.to_prepare do
  Wagn::Initializer.load
end
