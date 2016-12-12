# -*- encoding : utf-8 -*-
require "uglifier"

include_set Abstract::AceEditor

machine_input do
  js = format(:js)._render_core
  js = compress_js js if compress_js?
  comment_with_source js
end

def comment_with_source js
  "//#{name}\n#{js}"
end

def compress_js input
  Uglifier.compile(input)
rescue => e
  # CoffeeScript is compiled in a view
  # If there is a CoffeeScript syntax error we get the rescued view here
  # and the error that the rescued view is no valid Javascript
  # To get the original error we have to refer to Card::Error.current
  raise Card::Error, compression_error_message(e)
end

def compression_error_message e
  if Card::Error.current
    Card::Error.current.message
  else
    "JavaScript::SyntaxError (#{name}): #{e.message}"
  end
end

def compress_js?
  !Rails.env.development?
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
  def default_editor_args args
    args[:ace_mode] ||= "javascript"
  end

  view :content_changes do |args|
    wrap_with(:pre) { super args }
  end

  view :core do |_args|
    process_content highlighted_js
  end

  def highlighted_js
    ::CodeRay.scan(_render_raw, :js).div
  end
end

def diff_args
  { diff_format: :text }
end
