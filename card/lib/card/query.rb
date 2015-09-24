# -*- encoding : utf-8 -*-

class Card
  class Query
    require_dependency 'card/query/clause'
    require_dependency 'card/query/value_clause'
    require_dependency 'card/query/ref_clause'


    include Clause
    include Attributes

    MODIFIERS = {};  %w{ conj return sort sort_as group dir limit offset }.each{|key| MODIFIERS[key.to_sym] = nil }

    OPERATORS = %w{ != = =~ < > in ~ }.inject({}) {|h,v| h[v]=nil; h }.merge({
      :eq    => '=',   :gt => '>',    :lt      => '<',
      :match => '~',   :ne => '!=',   'not in' => nil
    }.stringify_keys)


    PLUS_ATTRIBUTES = %w{ plus left_plus right_plus }

    ATTRIBUTES = {
      :basic           => %w{ name type_id content id key updater_id left_id right_id creator_id updater_id codename },
      :relational      => %w{ type part left right editor_of edited_by last_editor_of last_edited_by creator_of created_by member_of member },
      :plus_relational => PLUS_ATTRIBUTES,
      :ref_relational  => %w{ refer_to referred_to_by link_to linked_to_by include included_by },
      :conjunction     => %w{ and or all any },
      :special         => %w{ found_by not sort match complete extension_type },
      :ignore          => %w{ prepend append view params vars size }
    }.inject({}) {|h,pair| pair[1].each {|v| h[v.to_sym]=pair[0] }; h }

    DEFAULT_ORDER_DIRS =  { :update => "desc", :relevance => "desc" }
    CONJUNCTIONS = { :any=>:or, :in=>:or, :or=>:or, :all=>:and, :and=>:and }

    attr_reader :query, :selfname
    attr_accessor :sql, :joins, :table_seq

    def initialize query
      @mods = MODIFIERS.clone
      @conditions, @joins = {}, {}
      @selfname, @super = '', nil
      @subclauses = []
      @sql = SqlStatement.new

      @query = query.clone
      @query.merge! @query.delete(:params) if @query[:params]
      @vars = @query.delete(:vars) || {}
      @vars.symbolize_keys!

      @query = clean @query
      interpret @query.deep_clone
      self
    end


    def run
      retrn = query[:return].present? ? query[:return].to_s : 'card'
      if retrn == 'card'
        simple_run('name').map do |name|
          Card.fetch name, :new=>{}
        end
      else
        simple_run retrn
      end
    end


    def simple_run retrn
      rows = run_sql

      case retrn
      when 'name' #common case
        if query[:prepend] || query[:append]
          rows.map do |row|
            [ query[:prepend], row['name'], query[:append] ].compact * '+'
          end
        else
          rows.map { |row| row['name'] }
        end
      when 'count'
        rows.first['count'].to_i
      when 'raw'
        rows
      when /id$/
        rows.map { |row| row[retrn].to_i }
      else
        rows.map { |row| row[retrn]      }
      end
    end

    def run_sql
      ActiveRecord::Base.connection.select_all( to_sql )
    end


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # QUERY CLEANING - strip strings, absolutize names, replace contextual parameters
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    def clean query
      query = query.symbolize_keys
      if s = query.delete(:context) then @selfname = s end
      if p = query.delete(:_super) then @super   = p end
      query.each do |key,val|
        query[key] = clean_val val
      end
      query
    end

    def clean_val val
      case val
      when String
        if val =~ /^\$(\w+)$/
          val = @vars[$1.to_sym].to_s.strip
        end
        absolute_name val
      when Card::Name             ; clean_val val.s
      when Hash                   ; clean val
      when Array                  ; val.map { |v| clean_val v }
      when Integer, Float, Symbol ; val
      else                        ; raise BadQuery, "unknown WQL value type: #{val.class}"
      end
    end

    def root
      @super ? @super.root : self
    end


    def subclause opts={}
      subclause = Query.new opts.reverse_merge(:_super=>self)
      subclause.sql = sql
      @subclauses << subclause
      subclause
    end

    def absolute_name name
      name =~ /\b_/ ? name.to_name.to_absolute(root.selfname) : name
    end


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MERGE - reduce query to basic attributes and SQL subconditions
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    def interpret s
      s = normalize s
      translate_to_attributes s
      ready_to_sqlize s
      @conditions.merge! s
      self
    end

    def normalize s
      case s
        when Hash;     s
        when String;   { :key => s.to_name.key }
        when Integer;  { :id => s              }
        else;          raise BadQuery, "Invalid cardclause args #{s.inspect}"
      end
    end

    def translate_to_attributes clause
      content = nil
      clause.each do |key,val|
        if key == :_super
          @super = clause.delete(key)
        elsif OPERATORS.has_key?(key.to_s) && !ATTRIBUTES[key]
          clause.delete(key)
          content = [key,val]
        elsif MODIFIERS.has_key?(key)
          next if clause[key].is_a? Hash
          val = clause.delete key
          @mods[key] = Array === val ? val : val.to_s
        end
      end
      clause[:content] = content if content
    end


    def ready_to_sqlize clause
      clause.each do |key,val|
        keyroot = field_root(key).to_sym
        if keyroot==:cond                            # internal SQL cond (already ready)
        elsif ATTRIBUTES[keyroot] == :basic          # sqlize knows how to handle these keys; just process value
          clause[key] = ValueClause.new(val, self)
        else                                         # keys need additional processing
          val = clause.delete key
          is_array = Array===val
          case ATTRIBUTES[keyroot]
            when :ignore                               #noop
            when :conjunction                        ; send keyroot, val
            when :relational, :special               ; relate is_array, keyroot, val, :send
            when :ref_relational                     ; relate is_array, keyroot, val, :join_references
            when :plus_relational
              # Arrays can have multiple interpretations for these, so we have to look closer...
              subcond = is_array && ( Array===val.first || conjunction(val.first) )

                                                       relate subcond, keyroot, val, :send
            else                                     ; raise BadQuery, "Invalid attribute #{key}"
          end
        end
      end

    end

    def relate subcond, key, val, method
      if subcond
        conj = conjunction( val.first ) ? conjunction( val.shift ) : :and
        if conj == current_conjunction                # same conjunction as container, no need for subcondition
          val.each { |v| send method, key, v }
        else
          send conj, val.inject({}) { |h,v| h[field key] = v; h }  # subcondition
        end
      else
        send method, key, val
      end
    end




    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # SQL GENERATION - translate interpretd hash into complete SQL statement.
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



    def to_sql *args

      sql.tables = "cards #{table_alias}"
      sql.fields.unshift fields_to_sql
      sql.joins = build_joins

      sql.conditions = [ build_conditions, standard_table_conditions ].reject( &:blank? ).join " AND \n    "

      sql.order = sort_to_sql  # has side effects!

      sql.group = "GROUP BY #{safe_sql(@mods[:group])}" if !@mods[:group].blank?
      unless @super or @mods[:return]=='count'
        if @mods[:limit].to_i > 0
          sql.limit  = "LIMIT #{  @mods[:limit ].to_i }"
          sql.offset = "OFFSET #{ @mods[:offset].to_i }" if !@mods[:offset].blank?
        end
      end

      sql.to_s
    end


    def build_joins
      [ @joins.values, @subclauses.map( &:build_joins ) ].flatten.compact
    end

    def build_conditions
      cond_list = basic_conditions
      cond_list +=
        @subclauses.map do |clause|
          clause.build_conditions
        end
      cond_list.reject! &:blank?

      if cond_list.size > 1
        "(#{ cond_list.join " #{ current_conjunction.upcase }\n" })"
      else
        cond_list.join
      end
    end


    def basic_conditions
      @conditions.map do |key, val|
        val.to_sql field_root(key)
      end
    end

    def current_conjunction
      @mods[:conj].blank? ? :and : @mods[:conj]
    end

    def standard_table_conditions
      [trash_condition, permission_conditions].compact * ' AND '
    end

    def trash_condition
      "#{table_alias}.trash is false"
    end

    def permission_conditions
      unless Auth.always_ok?
        read_rules = Auth.as_card.read_rules
        read_rule_list = read_rules.nil? ? 1 : read_rules.join(',')
        "(#{table_alias}.read_rule_id IN (#{ read_rule_list }))"
      end
    end

    def fields_to_sql
      field = @mods[:return]
      case (field.blank? ? :card : field.to_sym)
      when :raw;  "#{table_alias}.*"
      when :card; "#{table_alias}.name"
      when :count; "coalesce(count(*),0) as count"
      when :content; "#{table_alias}.db_content"
      else
        ATTRIBUTES[field.to_sym]==:basic ? "#{table_alias}.#{field}" : safe_sql(field)
      end
    end

    def sort_to_sql
      #fail "order_key = #{@mods[:sort]}, class = #{order_key.class}"

      return nil if @super or @mods[:return]=='count' #FIXME - extend to all root-only clauses
      order_key ||= @mods[:sort].blank? ? "update" : @mods[:sort]

      order_directives = [order_key].flatten.map do |key|
        dir = @mods[:dir].blank? ? (DEFAULT_ORDER_DIRS[key.to_sym]||'asc') : safe_sql(@mods[:dir]) #wonky
        sort_field key, @mods[:sort_as], dir
      end.join ', '
      "ORDER BY #{order_directives}"

    end

    def sort_field key, as, dir
      order_field = case key
        when "id";              "#{table_alias}.id"
        when "update";          "#{table_alias}.updated_at"
        when "create";          "#{table_alias}.created_at"
        when /^(name|alpha)$/;  "LOWER( #{table_alias}.key )"
        when 'content';         "#{table_alias}.db_content"
        when "relevance";       "#{table_alias}.updated_at" #deprecated
        else
          safe_sql(key)
        end
      order_field = "CAST(#{order_field} AS #{cast_type(as)})" if as
      sql.fields << order_field if self == root  #a bit hacky?
      "#{order_field} #{dir}"

    end


    class SqlCond < String
      def to_sql(*args) self end
    end


    class SqlStatement
      attr_accessor :fields, :tables, :joins, :conditions, :group, :order, :limit, :offset, :distinct

      def initialize
        @fields, @joins, @conditions = [],[],[]
        @tables = @group = @order = @limit =  @offset = @distinct = nil
      end

      def to_s
        select = fields.reject(&:blank?) * ', '
        where = "WHERE #{conditions}" unless conditions.blank?

        ['(SELECT DISTINCT', select, 'FROM', tables, joins, where, group, order, limit, offset, ')'].compact * ' '
      end
    end

  end
end

