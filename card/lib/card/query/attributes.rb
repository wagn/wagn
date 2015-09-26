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
        acts_alias, actions_alias = "a#{table_id force=true}", "an#{table_id force=true}"

        joins <<  Join.new( from: self, to: ['card_acts', acts_alias, 'actor_id' ] )
        joins <<  Join.new( from: ['card_acts', acts_alias], to: ['card_actions', actions_alias, 'card_act_id'] )
        join_cards val, from_alias: actions_alias, from_field: 'card_id'
      end


      def edited_by val
        acts_alias, actions_alias = "a#{table_id force=true}", "an#{table_id force=true}"

        joins <<  Join.new( from: self, to: ['card_actions', actions_alias, 'card_id' ] )
        joins <<  Join.new( from: ['card_actions', actions_alias, 'card_act_id' ], to: ['card_acts', acts_alias] )
        join_cards val, from_alias: acts_alias, from_field: 'actor_id'
      end

      def last_editor_of val
        join_cards val, :to_field=>'updater_id'
      end

      def last_edited_by val
        restrict :updater_id, val
      end

      def creator_of val
        join_cards val, :to_field=>'creator_id'
      end

      def created_by val
        restrict :creator_id, val
      end

      def member_of val
        interpret :right_plus => [RolesID, {:refer_to=>val}]
      end

      def member val
        interpret :referred_to_by => {:left=>val, :right=>RolesID }
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
        junction_val = clause_to_hash(junction_clause).merge side=>part_clause
        join_cards junction_val, :to_field=>"#{ side==:left ? :right : :left}_id"
      end


      #~~~~~~ SPECIAL


      def found_by val

        cards = if Hash===val
          Query.new(val).run
        else
          Array.wrap(val).map do |v|
            Card.fetch val.to_name.to_absolute(root.context), :new=>{}
          end
        end

        cards.each do |c|
          unless c && [SearchTypeID,SetID].include?(c.type_id)
            raise BadQuery, %{"found_by" value needs to be valid Search, but #{c.name} is a #{c.type_name}}
          end
          interpret Query.new(c.get_query).statement
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

        interpret :cond=>cond
      end


      def complete(val)
        no_plus_card = (val=~/\+/ ? '' : "and right_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
        interpret :cond => " lower(name) LIKE lower(#{quote(val.to_s+'%')}) #{no_plus_card}"
      end

      def extension_type val
        # DEPRECATED LONG AGO!!!
        Rails.logger.info "using DEPRECATED extension_type in WQL"
        interpret :right_plus => AccountID
      end


      # ATTRIBUTE HELPERS


      def join_references key, val
        r = RefClause.new( key, val, self )
        joins << Join.new(:from=>self, :to=>r, :to_field=>r.infield)
        s = nil
        if r.cardquery
          s = join_cards r.cardquery, from_alias: r.table_alias, from_field: r.outfield
        end
        if r.conditions.any?
          s ||= subquery
          s.interpret :cond => r.conditions.map { |condition| "#{r.table_alias}.#{condition}" } * ' AND '
        end
      end


      def conjunction val
        if [String, Symbol].member? val.class
          CONJUNCTIONS[val.to_sym]
        end
      end


      def sort val
        return nil if @superquery
        val[:return] = val[:return] ? safe_sql(val[:return]) : 'db_content'
        val[:superquery] = self
        item = val.delete(:item) || 'left'

        if val[:return] == 'count'
          cs_args = { :return=>'count', :group=>'sort_join_field', :superquery=>self }
          @mods[:sort] = "coalesce(count,0)" # needed for postgres
          case item
          when 'referred_to'
            join_field = 'id'
            cs = Query.new cs_args.merge( :cond=>"referer_id in #{Query.new( val.merge(:return=>'id')).sql}" )
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

        cs.mods[:sort_join_field] = "#{cs.table_alias}.#{join_field} as sort_join_field" #HACK!
        join_table = add_join :sort, cs.sql, :id, :sort_join_field, :side=>'LEFT'
        @mods[:sort] ||= "#{join_table}.#{val[:return]}"

      end

      def table_alias
        @table_alias ||= begin
          if @mods[:return]=='condition' && @superquery
            @superquery.table_alias
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
        joins << ["\n  ", opts[:side], 'JOIN', table, 'AS', join_alias, 'ON', on, "\n"].compact.join(' ')
        join_alias
      end


      def join_cards val, opts={}
        # FIXME get rid of from_alias
        s = subquery
        join_opts = { from: self, to: s }.merge opts
        s.joins << Join.new( join_opts )
        s.interpret val
        s
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
      alias :in :any

      def conjoin val, conj
        clause = subquery( :return=>:condition, :conj=>conj )
        array = Array===val ? val : clause_to_hash(val).map { |key, value| {key => value} }
        array.each do |val_item|
          clause.interpret val_item
        end
      end

      def not val
        subselect = Query.new(:return=>:id, :superquery=>self)
        subselect.interpret(val)
        join_alias = add_join :not, subselect.sql, :id, :id, :side=>'LEFT'
        interpret :cond => "#{join_alias}.id is null"
      end

      def restrict id_field, val
        if id = id_from_val(val)
          interpret id_field => id
        else
          join_cards val, from_field: id_field
        end
      end

      def id_from_val val
        case val
        when Integer ; val
        when String  ; Card.fetch_id(val)
        end
      end

    end
  end
end