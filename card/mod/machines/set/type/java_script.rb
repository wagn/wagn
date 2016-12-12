# -*- encoding : utf-8 -*-

include_set Abstract::Script

include_set Abstract::Machine
include_set Abstract::MachineInput

store_machine_output filetype: "js"

machine_input do
  js = format(:js)._render_raw
  js = compress_js(js) if compress_js?
  comment_with_source js
end
