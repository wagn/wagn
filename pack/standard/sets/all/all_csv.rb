# -*- encoding : utf-8 -*-
require 'csv'

format :csv do
  def get_inclusion_defaults
    @@inclusion_defaults ||= [:core,:csvrow].map {|view| {:view=>view} }
    @@inclusion_defaults[@depth.to_i] || {:view=>:core}
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
