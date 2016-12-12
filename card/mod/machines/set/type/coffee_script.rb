# -*- encoding : utf-8 -*-
require "coffee-script"

include_set Abstract::Script
include_set Abstract::Machine
include_set Abstract::MachineInput

store_machine_output filetype: "js"

format :html do
  def default_editor_args args
    args[:ace_mode] ||= "coffee"
  end

  def highlighted_js
    ::CodeRay.scan(compiled_content, :js).div
  end
end

format do
  view :core do
    compiled_content
  end

  def compiled_content
    compile_coffee _render_raw
  end

  def compile_coffee script
    ::CoffeeScript.compile script
  rescue => e
    raise Card::Error, "CoffeeScript::Error (#{name}): #{e.message}"
  end
end
