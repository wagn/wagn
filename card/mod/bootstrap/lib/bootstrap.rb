require "bootstrap/component_loader"
require "bootstrap/component"

class Bootstrap
  include Delegate
  extend ComponentLoader
  load_components

  def initialize context=nil
    @context = context
  end

  def render *args, &block
    instance_exec *args, &block
  end
end
