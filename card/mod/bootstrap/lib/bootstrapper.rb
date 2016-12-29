require 'bootstrap'
module Bootstrapper
  extend Bootstrap::ComponentLoader

  def bootstrap
    @bootstrap ||= ::Bootstrap.new(self)
  end

  def bs *args, &block
    bootstrap.render *args, &block
  end

  components.each do |component|
    delegate component, to: :bootstrap, prefix: :bs
  end
end
