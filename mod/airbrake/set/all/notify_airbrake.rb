def notable_exception_raised exception
  super
  controller.send :notify_airbrake, exception if Airbrake.configuration.api_key
end
