class Card::Query
  class RefSpec < Spec
    REFSPECS = {
      :refer_to       => [:out],
      :link_to        => [:out, "ref_type='L'"],
      :include        => [:out, "ref_type='I'"],
      :link_to_missing=> [:out, "present = 0 AND ref_type='L'"],
      
      :referred_to_by => [:in], #superfluous...
      :linked_to_by   => [:in, "ref_type='L'"],
      :included_by    => [:in, "ref_type='I'"]
    }
        
    def initialize key, cardspec
      @key, @cardspec = key, cardspec
    end

    def to_sql *args
      dir, cond = REFSPECS[ @key.to_sym ]
      field1, field2 = dir==:out ? [ :referer_id, :referee_id] : [ :referee_id, :referer_id]
      
      where = [ cond, ("#{field2} IN #{ @cardspec.to_sql }" unless @key == :link_to_missing) ].compact
      %{(select #{field1} from card_references where #{ where * ' AND ' })}
    end
  end
end
