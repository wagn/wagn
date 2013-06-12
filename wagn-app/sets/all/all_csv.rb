# -*- encoding : utf-8 -*-
require 'csv'

format :csv do

  view :show do |args|
    if !card.collection?
      "CSV format only works on collections (searches, pointers, etc)"
    else
      super args.merge :item=>:csvrow
    end
  end

  view :csvrow do |args|
    array = _render_raw.scan( /\{\{[^\}]*\}\}/ ).map do |inc|
      process_content( inc ).strip
    end
    
    CSV.generate_line(array).strip
    #chop is because search already joins with newlines
  end

  view :missing do |args|
    ''
  end

end
