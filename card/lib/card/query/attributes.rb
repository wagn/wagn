
class Card
  class Query
    module Attributes
      SORT_JOIN_TO_ITEM_MAP = { left: 'left_id', right: 'right_id' }.freeze

      # ~~~~~~ RELATIONAL

      def type val
        restrict :type_id, val
      end

      def part val
        right_val = val.is_a?(Integer) ? val : val.clone
        any(left: val, right: right_val)
      end

      def left val
        restrict :left_id, val
      end

      def right val
        restrict :right_id, val
      end

      def editor_of val
        act_join = Join.new(
          from: self,
          to: ['card_acts', "a#{table_id true}", 'actor_id']
        )
        joins << act_join
        action_join = Join.new(
          from: act_join,
          to: ['card_actions', "an#{table_id true}", 'card_act_id'],
          superjoin: act_join
        )
        join_cards val, from: action_join, from_field: 'card_id'
      end

      def edited_by val
        action_join = Join.new(
          from: self,
          to: ['card_actions', "an#{table_id true}", 'card_id']
        )
        joins << action_join
        act_join = Join.new(
          from: action_join,
          from_field: 'card_act_id',
          to: ['card_acts', "a#{table_id true}"]
        )
        join_cards val, from: act_join, from_field: 'actor_id'
      end

      def last_editor_of val
        join_cards val, to_field: 'updater_id'
      end

      def last_edited_by val
        restrict :updater_id, val
      end

      def creator_of val
        join_cards val, to_field: 'creator_id'
      end

      def created_by val
        restrict :creator_id, val
      end

      def member_of val
        interpret right_plus: [RolesID, refer_to: val]
      end

      def member val
        interpret referred_to_by: { left: val, right: RolesID }
      end

      # ~~~~~~ PLUS RELATIONAL

      def left_plus val
        junction val, :left, :right_id
      end

      def right_plus val
        junction val, :right, :left_id
      end

      def plus val
        any(left_plus: val, right_plus: val.deep_clone)
      end

      def junction val, side, to_field
        part_clause, junction_clause = val.is_a?(Array) ? val : [val, {}]
        junction_val = clause_to_hash(junction_clause).merge side => part_clause
        join_cards junction_val, to_field: to_field
      end

      # ~~~~~~ SPECIAL

      def found_by val
        found_by_cards(val).compact.each do |c|
          if c && [SearchTypeID, SetID].include?(c.type_id)
            # FIXME: - move this check to set mods!

            subquery(
              c.get_query.merge unjoined: true, context: c.name
            )
          else
            raise BadQuery,
                  '"found_by" value must be valid Search, ' \
                  "but #{c.name} is a #{c.type_name}"
          end
        end
      end

      def found_by_cards val
        if val.is_a? Hash
          Query.run val
        else
          Array.wrap(val).map do |v|
            Card.fetch v.to_name.to_absolute(context), new: {}
          end
        end
      end

      def match val
        cxn, val = match_prep val
        val.gsub! /[^#{Card::Name::OK4KEY_RE}]+/, ' '
        return nil if val.strip.empty?

        val_list = val.split(/\s+/).map do |v|
          name_or_content = [
            "replace(#{table_alias}.name,'+',' ')",
            "#{table_alias}.db_content"
          ].map do |field|
            %(#{field} #{cxn.match quote("[[:<:]]#{v}[[:>:]]")})
          end
          "(#{name_or_content.join ' OR '})"
        end
        add_condition "(#{val_list.join ' AND '})"
      end

      def complete val
        no_plus_card = (val =~ /\+/ ? '' : 'and right_id is null')
        # FIXME: -- this should really be more nuanced --
        # it breaks down after one plus

        add_condition(
          " lower(#{table_alias}.name) LIKE" \
          " lower(#{quote(val.to_s + '%')}) #{no_plus_card}"
        )
      end

      def extension_type _val
        # DEPRECATED LONG AGO!!!
        Rails.logger.info 'using DEPRECATED extension_type in WQL'
        interpret right_plus: AccountID
      end

      # ATTRIBUTE HELPERS

      def join_references key, val
        r = Reference.new(key, val, self)
        refjoin = Join.new(from: self, to: r, to_field: r.infield)
        joins << refjoin
        if r.cardquery
          join_cards r.cardquery, from: refjoin, from_field: r.outfield
        end
        r.conditions.each do |condition|
          refjoin.conditions << "#{r.table_alias}.#{condition}"
        end
      end

      def conjunction val
        return unless [String, Symbol].member? val.class
        CONJUNCTIONS[val.to_sym]
      end

      def sort val
        return nil if @superquery
        sort_field = val[:return] || 'db_content'
        item = val.delete(:item) || 'left'

        if sort_field == 'count'
          sort_by_count val, item
        else
          if (join_field = SORT_JOIN_TO_ITEM_MAP[item.to_sym])
            sq = join_cards(val, to_field: join_field,
                                 side: 'LEFT',
                                 conditions_on_join: true)
            @mods[:sort] ||= "#{sq.table_alias}.#{sort_field}"
          else
            raise BadQuery, "sort item: #{item} not yet implemented"
          end
        end
      end

      # EXPERIMENTAL!
      def sort_by_count val, item
        if item == 'referred_to'
          @mods[:sort] = 'coalesce(count,0)' # needed for postgres
          cs = Query.new(
            return: 'coalesce(count(*), 0) as count',
            group: 'sort_join_field',
            superquery: self
          )
          subselect = Query.new(val.merge return: 'id', superquery: self)
          cs.add_condition "referer_id in (#{subselect.sql})"
          # FIXME: - SQL generated before SQL phase
          cs.joins << Join.new(
            from: cs,
            to: %w(card_references wr referee_id)
          )
          cs.mods[:sort_join_field] = "#{cs.table_alias}.id as sort_join_field"
          # HACK!

          joins << Join.new(
            from: self,
            to: [cs, 'srtbl', 'sort_join_field']
          )
        else
          raise BadQuery, "count with item: #{item} not yet implemented"
        end
      end

      def table_alias
        @table_alias ||= begin
          if @unjoined
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
        conditions_on_join = opts.delete :conditions_on_join
        s = subquery
        card_join = Join.new({ from: self, to: s }.merge opts)
        joins << card_join unless opts[:from].is_a? Join
        s.conditions_on_join = card_join if conditions_on_join
        s.interpret val
        s
      end

      # ~~~~~~~  CONJUNCTION

      def all val
        conjoin val, :and
      end
      alias and all

      def any val
        conjoin val, :or
      end
      alias or any
      alias in any

      def conjoin val, conj
        sq = subquery unjoined: true, conj: conj
        unless val.is_a? Array
          val = clause_to_hash(val).map { |key, value| { key => value } }
        end
        val.each do |val_item|
          sq.interpret val_item
        end
      end

      def not val
        notjoin = join_cards val, conditions_on_join: true, side: 'LEFT'
        add_condition "#{notjoin.table_alias}.id is null"
      end

      def restrict id_field, val
        if (id = id_from_val(val))
          interpret id_field => id
        else
          join_cards val, from_field: id_field
        end
      end

      def id_from_val val
        case val
        when Integer then val
        when String  then Card.fetch_id(val)
        end
      end
    end
  end
end
