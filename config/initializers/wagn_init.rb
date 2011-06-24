
ActionController::Dispatcher.to_prepare do
  STDERR << "to_prepare #{Kernel.caller[0..20]*"\n"}\n>>>end"
  Wagn::Initializer.load
end
