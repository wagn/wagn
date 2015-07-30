# -*- encoding : utf-8 -*-
include Html

format do
  include Html::Format
  view :editor do |args|
    text_area :content, :rows=>5, :class=>'card-content ace-editor-textarea', "data-card-type-code"=>card.type_code
  end
end

format :html do
  view :core do |args|
    with_inclusion_mode :template do
      process_content ::CodeRay.scan( _render_raw, :html ).div
    end
  end
end