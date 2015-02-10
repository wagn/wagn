class Card::Query
  class RefClause < Clause
    REFERENCE_DEFINITIONS = {
      # syntax:
      # wql query key => [ direction, {reference_type} ]
          # direction      = :out | :in
          # reference_type =  'L' | 'I' | 'P' 

      :refer_to => [ :out, 'L','I' ], :referred_to_by => [ :in, 'L','I' ],
      :link_to  => [ :out, 'L' ],     :linked_to_by   => [ :in, 'L' ],
      :include  => [ :out, 'I' ],     :included_by    => [ :in, 'I' ]
    }
    
    REFERENCE_FIELDS = {
      :out => [ :referer_id, :referee_id ],
      :in  => [ :referee_id, :referer_id ]
    }
        
    def initialize key, val, parent
      @key, @val, @parent = key, val, parent
    end

    def to_sql *args
      dir, *type = REFERENCE_DEFINITIONS[ @key.to_sym ]
      field1, field2 = REFERENCE_FIELDS[ dir ]
      cond = []
      if type.present?
        operator = (type.size==1 ? '=' : 'IN')
        quoted_letters = type.map { |letter| "'#{letter}'" } * ', '
        cond << "ref_type #{operator} (#{quoted_letters})"
      end

      sql =  %[select distinct #{field1} as ref_id from card_references]
      if @val == '_none'
        cond << "present = 0"
      else
        cardclause = CardClause.build(:return=>'id', :_parent=>@parent).merge(@val)
        sql << %[ join #{ cardclause.to_sql } as c on #{field2} = c.id]
      end
      sql << %[ where #{ cond * ' and ' }] if cond.any?
      
      "(#{sql})"
    end
  end
end


