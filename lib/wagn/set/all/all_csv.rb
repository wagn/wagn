# -*- encoding : utf-8 -*-
require 'csv'

module Wagn
  module Set::All::AllCsv
    include Sets

    format :csv

    define_view :show do |args|
      if !card.collection?
        "CSV format only works on collections (searches, pointers, etc)"
      else
        super args.merge :item=>:csvrow
      end
    end

    define_view :csvrow do |args|
      array = _render_raw.scan( /\{\{[^\}]*\}\}/ ).map do |inc|
        process_content( inc ).strip
      end
      
      CSV.generate_line(array).strip
      #chop is because search already joins with newlines
    end

    define_view :missing do |args|
      ''
    end

  end
end
