# -*- encoding : utf-8 -*-
require "coffee-script"

include_set Abstract::Script

format :html do
  def default_editor_args args
    args[:ace_mode] ||= "coffee"
  end
end

format do
  view :core do
    compile_coffee _render_raw
  end

  def compile_coffee script
    ::CoffeeScript.compile script
  rescue => e
    raise Card::Error, "CoffeeScript::Error (#{card.name}): #{e.message}"
  end
end
