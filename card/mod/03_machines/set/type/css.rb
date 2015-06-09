# -*- encoding : utf-8 -*-
require 'sass'
include Machine
include MachineInput

store_machine_output :filetype => "css"

machine_input do
  compress_css format(:format => :css)._render_core
end

def compress_css input
  begin
    Sass.compile input, :style=>:compressed
  rescue => e
    raise Card::Oops, "Stylesheet Error:\n#{ e.message }"
  end
end

def clean_html?
  false
end

format do
  def chunk_list  #turn off autodetection of uri's
    :references
  end
end


format :html do
  def get_inclusion_defaults nested_card
    { :view => :closed }
  end

  view :editor, :mod=>PlainText::HtmlFormat

  view :core do |args|
    # FIXME: scan must happen before process for inclusion interactions to work, but this will likely cause
    # problems with including other css?
    process_content ::CodeRay.scan( _render_raw, :css ).div, :size=>:icon
  end

  view :content_changes, :mod=>CoffeeScript::HtmlFormat
end

def diff_args
   {:format=>:text}
end
