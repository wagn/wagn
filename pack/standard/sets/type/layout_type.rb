# -*- encoding : utf-8 -*-
include Card::Set::Type::Html

view :editor, :type=>:html
view :closed_content, :type=>:html

view :core do |args|
  with_inclusion_mode :template do
    process_content ::CodeRay.scan( _render_raw, :html ).div
  end
end
