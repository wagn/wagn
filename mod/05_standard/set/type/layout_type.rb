# -*- encoding : utf-8 -*-
include Html

format do
  include Html::Format
end

format :html do
  view :core do |args|
    with_inclusion_mode :template do
      process_content ::CodeRay.scan( _render_raw, :html ).div
    end
  end
end