
=begin
require 'rails/all'

module Wagn
  if defined? ::Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie

    end
  end
end
=end
