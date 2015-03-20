require 'csv'

format :csv  do
  def get_inclusion_defaults nested_card
    { :view => :core }
  end
  
  def default_item_view 
    @depth == 0 ? :csv_row : :name
  end

  
  view :csv_row do |args|
    array = _render_raw.scan( /\{\{[^\}]*\}\}/ ).map do |inc|
      process_content( inc ).strip
    end
    
    CSV.generate_line(array).strip
    #strip is because search already joins with newlines
  end

  view :missing do |args|
    ''
  end

  view :csv_title_row do |args|
    #NOTE: assumes all cards have the same structure!
    begin
      card1 = search_results.first
    
      parsed_content = Card::Content.new card1.raw_content, self
      unless String === parsed_content.__getobj__
        titles = parsed_content.map do |chunk|
          next if chunk.class != Card::Chunk::Include
          opts = chunk.options
          if ['name','link'].member? opts[:view]
            opts[:view]
          else
            opts[:inc_name].to_name.tag
          end
        end.compact.map {|title| title.to_s.upcase }
        CSV.generate_line titles
        
      else
        ''
      end
    rescue
      ''
    end
  end

end
