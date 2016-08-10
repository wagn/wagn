# -*- encoding : utf-8 -*-
require "sass"
include Machine
include MachineInput
include_set Abstract::AceEditor

store_machine_output filetype: "css"

machine_input do
  compress_css format(format: :css)._render_core
end

def compress_css input
  Sass.compile input, style: :compressed
rescue => e
  # scss is compiled in a view
  # If there is a scss syntax error we get the rescued view here
  # and the error that the rescued view is no valid css
  # To get the original error we have to refer to Card::Error.current
  msg = if Card::Error.current
          Card::Error.current.message
        else
          "Sass::SyntaxError (#{name}): #{e.message}"
        end
  raise Card::Error, msg
end

def clean_html?
  false
end

format do
  def chunk_list # turn off autodetection of uri's
    :references
  end
end

format :html do
  def default_editor_args args
    args[:ace_mode] = "css"
  end

  def get_nest_defaults _nested_card
    { view: :closed }
  end

  view :core do |_args|
    # FIXME: scan must happen before process for inclusion interactions to
    # work, but this will likely cause
    # problems with including other css?
    process_content ::CodeRay.scan(_render_raw, :css).div,
                    content_opts: { size: :icon }
  end

  view :content_changes, mod: Abstract::Script::HtmlFormat
end

def diff_args
  { format: :text }
end
