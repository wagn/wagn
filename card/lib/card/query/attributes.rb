#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ATTRIBUTE METHODS - called during interpret
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Card
  class Query
    module Attributes

      SORT_JOIN_TO_ITEM_MAP = { :left=>'left_id', :right=>'right_id'}

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

        val_list = val.split(/\s+/).map do |v|
          name_or_content = ["replace(#{self.table_alias}.name,'+',' ')","#{self.table_alias}.db_content"].map do |field|
            %{#{field} #{ cxn.match quote("[[:<:]]#{v}[[:>:]]") }}
          end
          "(#{name_or_content.join ' OR '})"
        end
        add_condition "(#{val_list.join ' AND '})"
      end


      def complete(val)
        no_plus_card = (val=~/\+/ ? '' : "and right_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
        add_condition " lower(name) LIKE lower(#{quote(val.to_s+'%')}) #{no_plus_card}"
      end

      def extension_type val
        # DEPRECATED LONG AGO!!!
        Rails.logger.info "using DEPRECATED extension_type in WQL"
        interpret :right_plus => AccountID
      end


      # ATTRIBUTE HELPERS


      def join_references key, val
        r = Reference.new( key, val, self )
        joins << Join.new(:from=>self, :to=>r, :to_field=>r.infield)
        s = nil
        if r.cardquery
          s = join_cards r.cardquery, from_alias: r.table_alias, from_field: r.outfield
        end
        if r.conditions.any?
          s ||= subquery
          s.add_condition r.conditions.map { |condition| "#{r.table_alias}.#{condition}" } * ' AND '
        end
      end

      def conjunction val
        if [String, Symbol].member? val.class
          CONJUNCTIONS[val.to_sym]
        end
      end

      def sort val
        return nil if @superquery
        sort_field = val[:return] || 'db_content'
        item = val.delete(:item)  || 'left'

        if sort_field == 'count'
          sort_by_count val, item
        else
          join_field = SORT_JOIN_TO_ITEM_MAP[item.to_sym] or raise BadQuery, "sort item: #{item} not yet implemented"
          sq = join_cards val, to_field: join_field, side: 'LEFT', conditions_on_join: true
          @mods[:sort] ||= "#{sq.table_alias}.#{sort_field}"
        end

      end

      # EXPERIMENTAL!
      def sort_by_count val, item
        raise BadQuery, "count with item: #{item} not yet implemented" unless item == 'referred_to'
        @mods[:sort] = "coalesce(count,0)" # needed for postgres
        cs = Query.new :return=>'count', :group=>'sort_join_field', :superquery=>self
        cs.add_condition "referer_id in (#{Query.new( val.merge(return: 'id', superquery: self)).sql})"
        # FIXME - SQL generated before SQL phase
        cs.joins << Join.new(from: cs, to:['card_references', 'wr', 'referee_id'])
        cs.mods[:sort_join_field] = "#{cs.table_alias}.id as sort_join_field" #HACK!
        @joins << Join.new( from: self, to: [cs, 'srtbl', 'sort_join_field'] )
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

      def join_cards val, opts={}
        conditions_on_join = opts.delete(:conditions_on_join)
        s = subquery
        s.joins << Join.new( { from: self, to: s }.merge opts )
        s.conditions_on_join = conditions_on_join
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
        sq = subquery( :return=>:condition, :conj=>conj )
        unless Array===val
          val = clause_to_hash(val).map { |key, value| { key => value } }
        end
        val.each do |val_item|
          sq.interpret val_item
        end
      end

      def not val
        subselect = Query.new clause_to_hash(val).merge( :return=>:id )
        join_alias = "not#{table_id force=true}"
        @joins << Join.new( from: self, to_table: subselect, to_alias: join_alias, :side=>'LEFT' )
        add_condition "#{join_alias}.id is null"
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