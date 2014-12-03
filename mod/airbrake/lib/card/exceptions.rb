class Card
  def self.exception_raised exception
    controller.send :notify_airbrake, exception if Airbrake.configuration.api_key
    super
  end
end
