# -*- encoding : utf-8 -*-
    
format :css do

  def get_inclusion_defaults
    { :view => :content }
  end
  
  view :content do |args|
    %(/* -- Style Card: #{card.name} -- */\n\n#{ _render_core args })
  end
  
  view :missing do |args|
    "/*-- MISSING Style Card: #{card.name} --*/"
  end

  view :show do |args|
    view = args[:view] || :content
    render view
  end
    
end
