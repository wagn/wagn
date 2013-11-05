class Card::Query
  class RefSpec < Spec
    REFSPECS = {
      :refer_to       => ['referer_id','referee_id',''],
      :link_to        => ['referer_id','referee_id',"ref_type='L' AND"],
      :include        => ['referer_id','referee_id',"ref_type='I' AND"],
      :link_to_missing=> ['referer_id','referee_id',"present = 0 AND ref_type='L'"],
      :referred_to_by => ['referee_id','referer_id',''],
      :linked_to_by   => ['referee_id','referer_id',"ref_type='L' AND"],
      :included_by    => ['referee_id','referer_id',"ref_type='I' AND"]
    }
    
    def initialize key, cardspec
      @key, @cardspec = key, cardspec
    end

    def to_sql *args
      field1, field2, where = REFSPECS[ @key.to_sym ]
      and_where = @key != :link_to_missing && "#{ field2 } IN #{ @cardspec.to_sql }"
      %{(select #{field1} from card_references where #{where} #{and_where})}
    end
  end
end
