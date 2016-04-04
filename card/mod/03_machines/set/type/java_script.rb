# -*- encoding : utf-8 -*-
require 'uglifier'

include Machine
include MachineInput

store_machine_output filetype: 'js'

machine_input do
  compress_js format(:js)._render_core
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

def clean_html?
  false
end

format do
  def chunk_list  # turn off autodetection of uri's
    :nest_only
  end
end

format :html do
  view :editor, mod: Html::HtmlFormat
  view :content_changes, mod: CoffeeScript::HtmlFormat

  view :core do |_args|
    highlighted_js = ::CodeRay.scan(_render_raw, :js).div
    process_content highlighted_js
  end
end

def diff_args
  { format: :text }
end
