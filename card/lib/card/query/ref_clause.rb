class Card::Query
  class RefClause
    include Clause
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

    attr_accessor :conditions, :cardquery, :infield, :outfield

    def table_alias
      @table_alias ||= "cr#{@parent.table_id force=true}"
    end


    def initialize key, val, parent
      key, val, @parent = key, val, parent
      @conditions = []

      dir, *type = REFERENCE_DEFINITIONS[ key.to_sym ]
      @infield, @outfield = REFERENCE_FIELDS[ dir ]

      if type.present?
        operator = (type.size==1 ? '=' : 'IN')
        quoted_letters = type.map { |letter| "'#{letter}'" } * ', '
        @conditions << "ref_type #{operator} (#{quoted_letters})"
      end

      if val == '_none'
        @conditions << "present = 0"
      else
        @cardquery = val
      end

      self

    end
  end
end


