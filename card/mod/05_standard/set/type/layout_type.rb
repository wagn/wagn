# -*- encoding : utf-8 -*-
include Html

format do
  include Html::Format
end

format :html do
  include Html::HtmlFormat

  view :core do |_args|
    with_nest_mode :template do
      process_content ::CodeRay.scan(_render_raw, :html).div
    end
  end
end
