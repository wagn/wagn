# -*- encoding : utf-8 -*-
require "coffee-script"

include_set Abstract::Script

require_dependency "card/machine"
require_dependency "card/machine_input"

include Machine
include MachineInput

store_machine_output filetype: "js"

machine_input do
  js = Uglifier.compile compile_coffee(format(:js)._render_raw)
  comment_with_source js
end

def compile_coffee script
  ::CoffeeScript.compile script
rescue => e
  raise Card::Error, "CoffeeScript::Error (#{name}): #{e.message}"
end

format :html do
  def default_editor_args args
    args[:ace_mode] ||= "coffee"
  end

  def highlighted_js
    js = card.compile_coffee _render_raw
    ::CodeRay.scan(js, :js).div
  end
end

format do
  view :core do |_args|
    process_content card.compile_coffee(_render_raw)
  end
end
