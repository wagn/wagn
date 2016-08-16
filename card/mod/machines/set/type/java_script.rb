# -*- encoding : utf-8 -*-

include_set Abstract::Script

include Machine
include MachineInput

store_machine_output filetype: "js"

machine_input do
  js = compress_js format(:js)._render_core
  comment_with_source js
end

def compress_js input
  Uglifier.compile(input)
rescue => e
  # CoffeeScript is compiled in a view
  # If there is a CoffeeScript syntax error we get the rescued view here
  # and the error that the rescued view is no valid Javascript
  # To get the original error we have to refer to Card::Error.current
  msg = if Card::Error.current
          Card::Error.current.message
        else
          "CoffeeScript::SyntaxError (#{name}): #{e.message}"
        end
  raise Card::Error, msg
end

