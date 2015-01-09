class Card::Query
  class RefSpec < Spec
    REFERENCE_DEFINITIONS = {
      :refer_to => [ :out      ],   :referred_to_by => [ :in      ],
      :link_to  => [ :out, 'L' ],   :linked_to_by   => [ :in, 'L' ],
      :include  => [ :out, 'I' ],   :included_by    => [ :in, 'I' ]
    }
    
    REFERENCE_FIELDS = {
      :out => [ :referer_id, :referee_id ],
      :in  => [ :referee_id, :referer_id ]
    }
        
    def initialize key, val, parent
      @key, @val, @parent = key, val, parent
    end

    def to_sql *args
      dir, type = REFERENCE_DEFINITIONS[ @key.to_sym ]
      field1, field2 = REFERENCE_FIELDS[ dir ]
      cond = type ? ["ref_type='#{type}'"] : []

      sql =  %[select distinct #{field1} as ref_id from card_references]
      if @val == '_none'
        cond << "present = 0"
      else
        cardspec = CardSpec.build(:return=>'id', :_parent=>@parent).merge(@val)
        sql << %[ join #{ cardspec.to_sql } as c on #{field2} = c.id]
      end
      sql << %[ where #{ cond * ' and ' }] if cond.any?
      
      "(#{sql})"
    end
  end
end


