# -*- encoding : utf-8 -*-

format :text do

  view :core do |args|
    HTMLEntities.new.decode strip_tags( process_content _render_raw )
  end

end
