#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ATTRIBUTE METHODS - called during interpret
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Card
  class Query
    module Attributes

      #~~~~~~ RELATIONAL

      def type val
        restrict :type_id, val
      end

      def part val
        right_val = Integer===val ? val : val.clone
        any( :left=>val, :right=>right_val)
      end

      def left val
        restrict :left_id, val
      end

      def right val
        restrict :right_id, val
      end



      def editor_of val
        acts_tbl    = "a#{table_id force=true}"
        actions_tbl = "an#{table_id force=true}"

        joins[field(:actor_id)] = %(
        #{join_table} card_acts #{acts_tbl} ON #{table_alias}.id = #{acts_tbl}.#{:actor_id}
        JOIN card_actions #{actions_tbl} ON #{acts_tbl}.id = #{actions_tbl}.card_act_id
        )

        sub = join_cards :card_id, val, :join_to=>actions_tbl
      end


      def edited_by val
        acts_tbl    = "a#{table_id force=true}"
        actions_tbl = "an#{table_id force=true}"

        joins[field(:actor_id)] = %(
        #{join_table} card_actions #{actions_tbl} ON #{table_alias}.id = #{actions_tbl}.card_id
        JOIN card_acts #{acts_tbl} ON #{actions_tbl}.card_act_id = #{acts_tbl}.id
        )

        sub = join_cards :actor_id, val, :join_to=>acts_tbl
      end

      def last_editor_of val
        join_cards :id, val, :return=>'updater_id'
      end

      def last_edited_by val
        restrict :updater_id, val
      end

      def creator_of val
        join_cards :id, val, :return=>'creator_id'
      end

      def created_by val
        restrict :creator_id, val
      end

      def member_of val
        interpret field(:right_plus) => [RolesID, {:refer_to=>val}]
      end

      def member val
        interpret field(:referred_to_by) => {:left=>val, :right=>RolesID }
      end


      #~~~~~~ PLUS RELATIONAL

      def left_plus val
        junction :left, val
      end

      def right_plus val
        junction :right, val
      end

      def plus val
        any( { :left_plus=>val, :right_plus=>val.deep_clone } )
      end

      def junction side, val
        part_clause, junction_clause = val.is_a?(Array) ? val : [ val, {} ]
        junction_val = normalize(junction_clause).merge side=>part_clause
        join_cards :id, junction_val, :return=>"#{ side==:left ? :right : :left}_id"
      end


      #~~~~~~ SPECIAL


      def found_by val

        cards = if Hash===val
          Query.new(val).run
        else
          Array.wrap(val).map do |v|
            Card.fetch absolute_name(val), :new=>{}
          end
        end

        cards.each do |c|
          unless c && [SearchTypeID,SetID].include?(c.type_id)
            raise BadQuery, %{"found_by" value needs to be valid Search, but #{c.name} is a #{c.type_name}}
          end
          #FIXME - this is silly.  joining id on id??
          join_cards :id, Query.new(c.get_query).query.deep_clone
        end
      end


      def match(val)
        cxn, val = match_prep val
        val.gsub! /[^#{Card::Name::OK4KEY_RE}]+/, ' '
        return nil if val.strip.empty?


        cond = begin
          val_list = val.split(/\s+/).map do |v|
            name_or_content = ["replace(#{self.table_alias}.name,'+',' ')","#{self.table_alias}.db_content"].map do |field|
              %{#{field} #{ cxn.match quote("[[:<:]]#{v}[[:>:]]") }}
            end
            "(#{name_or_content.join ' OR '})"
          end
          "(#{val_list.join ' AND '})"
        end

        interpret field(:cond)=>SqlCond.new(cond)
      end


      def complete(val)
        no_plus_card = (val=~/\+/ ? '' : "and right_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
        interpret field(:cond) => SqlCond.new(" lower(name) LIKE lower(#{quote(val.to_s+'%')}) #{no_plus_card}")
      end

      def extension_type val
        # DEPRECATED LONG AGO!!!
        Rails.logger.info "using DEPRECATED extension_type in WQL"
        interpret field(:right_plus) => AccountID
      end


      # ATTRIBUTE HELPERS


      def join_references key, val
        #FIXME - this is SQL before SQL phase!!

        r = RefClause.new( key, val, self )

        joins[field(key)] = "\n#{join_table} card_references #{r.table_alias} ON #{table_alias}.id = #{r.table_alias}.#{r.infield}\n"
        s = nil
        if r.cardquery
          s = join_cards r.outfield, r.cardquery, :join_to=>r.table_alias
        end
        if r.conditions.any?
          s ||= subclause
          s.add_condition r.conditions.map { |condition| "#{r.table_alias}.#{condition}" } * ' AND '
        end
      end

      def add_condition condition
        interpret field(:cond) => SqlCond.new(condition)
      end


      def conjunction val
        if [String, Symbol].member? val.class
          CONJUNCTIONS[val.to_sym]
        end
      end






      def sort val
        return nil if @super
        val[:return] = val[:return] ? safe_sql(val[:return]) : 'db_content'
        val[:_super] = self
        item = val.delete(:item) || 'left'

        if val[:return] == 'count'
          cs_args = { :return=>'count', :group=>'sort_join_field', :_super=>self }
          @mods[:sort] = "coalesce(count,0)" # needed for postgres
          case item
          when 'referred_to'
            join_field = 'id'
            cs = Query.new cs_args.merge( field(:cond)=>SqlCond.new("referer_id in #{Query.new( val.merge(:return=>'id')).to_sql}") )
            cs.add_join :wr, :card_references, :id, :referee_id
          else
            raise BadQuery, "count with item: #{item} not yet implemented"
          end
        else
          join_field = case item
            when 'left'  ; 'left_id'
            when 'right' ; 'right_id'
            else         ;  raise BadQuery, "sort item: #{item} not yet implemented"
          end
          cs = Query.new(val)
        end

        cs.sql.fields << "#{cs.table_alias}.#{join_field} as sort_join_field"
        join_table = add_join :sort, cs.to_sql, :id, :sort_join_field, :side=>'LEFT'
        @mods[:sort] ||= "#{join_table}.#{val[:return]}"

      end



      def table_alias
        @table_alias ||= begin
          if @mods[:return]=='condition' && @super
            @super.table_alias
          else
            "c#{table_id}"
          end
        end
      end

      def table_id force=false
        if force
          tick_table_seq!
        else
          @table_id ||= tick_table_seq!
        end
      end

      def tick_table_seq!
        root.table_seq = root.table_seq.to_i + 1
      end

      def add_join(name, table, cardfield, otherfield, opts={})
        join_alias = "#{name}_#{table_id force=true}"
        on = "#{table_alias}.#{cardfield} = #{join_alias}.#{otherfield}"
        @joins[join_alias] = ["\n  ", opts[:side], 'JOIN', table, 'AS', join_alias, 'ON', on, "\n"].compact.join ' '
        join_alias
      end

      def join_table
        @mods[:conj] == 'or' ? 'LEFT JOIN' : 'JOIN'
      end


      def field name
        @fields ||= {}
        @fields[name] ||= 0
        @fields[name] += 1
        "#{ name }_#{ @fields[name] }"
      end

      def field_root key
        key.to_s.gsub /\_\d+/, ''
      end


      def id_from_clause clause
        case clause
        when Integer ; clause
        when String  ; Card.fetch_id(clause)
        end
      end


      #~~~~~~~  CONJUNCTION

      def all val
        conjoin val, :and
      end
      alias :and :all

      def any val
        conjoin val, :or
      end
      alias :or :any

      def conjoin val, conj
        clause = subclause( :return=>:condition, :conj=>conj )
        array = Array===val ? val : normalize(val).map { |key, value| {field(key) => value} }
        array.each do |val_item|
          clause.interpret val_item
        end
      end

      def not val
        subselect = Query.new(:return=>:id, :_super=>self).interpret(val).to_sql
        join_alias = add_join :not, subselect, :id, :id, :side=>'LEFT'
        interpret field(:cond) => SqlCond.new("#{join_alias}.id is null")
      end

      def restrict id_field, val
        if id = id_from_clause(val)
          interpret field(id_field) => id
        else
          join_cards id_field, val
        end
      end


      def join_cards sub_field, val, opts={}
        super_field = opts[:return]  || 'id'
        join_to     = opts[:join_to] || table_alias

        #FIXME - this is SQL before SQL phase!!
        s = subclause
        s.joins[field(sub_field)] = "
  #{join_table} cards #{s.table_alias} ON #{join_to}.#{sub_field} = #{s.table_alias}.#{super_field}
      AND #{s.standard_table_conditions}"
        s.interpret(val)
        s
      end

    end
  end
end