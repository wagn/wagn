# -*- encoding : utf-8 -*-
require "coffee-script"
require "uglifier"

require_dependency "card/machine"
require_dependency "card/machine_input"

include Machine
include MachineInput

include_set Abstract::AceEditor

def compile_coffee script
  ::CoffeeScript.compile script
rescue => e
  raise Card::Error, "CoffeeScript::Error (#{name}): #{e.message}"
end

machine_input do
  Uglifier.compile(compile_coffee format(:js)._render_raw)
end

store_machine_output filetype: "js"

def clean_html?
  false
end

format do
  def chunk_list  # turn off autodetection of uri's
    :nest_only
  end
end

format :html do
  def default_editor_args args
    args[:ace_mode] ||= "coffee"
  end

  view :content_changes do |args|
    %(
      <pre>#{super(args)}</pre>
    )
  end

  view :core do |_args|
    js = card.compile_coffee _render_raw
    highlighted_js = ::CodeRay.scan(js, :js).div
    process_content highlighted_js
  end
end

format do
  view :core do |_args|
    process_content card.compile_coffee(_render_raw)
  end
end

def diff_args
  { format: :text }
end
