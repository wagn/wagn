# -*- encoding : utf-8 -*-

class Card
  class Query
    require_dependency 'card/query/clause'
    require_dependency 'card/query/value_clause'
    require_dependency 'card/query/ref_clause'
    require_dependency 'card/query/attributes'
    require_dependency 'card/query/sql_statement'
    require_dependency 'card/query/join'

    include Clause
    include Attributes

    MODIFIERS = {};  %w{ conj return sort sort_as group dir limit offset }.each{|key| MODIFIERS[key.to_sym] = nil }

    OPERATORS = %w{ != = =~ < > in ~ }.inject({}) {|h,v| h[v]=nil; h }.merge({
      :eq    => '=',   :gt => '>',    :lt      => '<',
      :match => '~',   :ne => '!=',   'not in' => nil
    }.stringify_keys)

    ATTRIBUTES = {
      :basic           => %w{ name type_id content id key updater_id left_id right_id creator_id updater_id codename },
      :relational      => %w{ type part left right editor_of edited_by last_editor_of last_edited_by creator_of created_by member_of member },
      :plus_relational => %w{ plus left_plus right_plus },
      :ref_relational  => %w{ refer_to referred_to_by link_to linked_to_by include included_by },
      :conjunction     => %w{ and or all any },
      :special         => %w{ found_by not sort match complete extension_type },
      :ignore          => %w{ prepend append view params vars size }
    }.inject({}) {|h,pair| pair[1].each {|v| h[v.to_sym]=pair[0] }; h }

    DEFAULT_ORDER_DIRS =  { :update => "desc", :relevance => "desc" }
    CONJUNCTIONS = { :any=>:or, :in=>:or, :or=>:or, :all=>:and, :and=>:and }

    attr_reader :statement, :context, :mods, :conditions, :subqueries, :superquery
    attr_accessor :joins, :table_seq

    def initialize statement
      @subqueries, @joins, @conditions = [], [], []

      @mods = MODIFIERS.clone
      @statement = statement.clone

      @context    = @statement.delete(:context)    || ''
      @superquery = @statement.delete(:superquery) || nil
      @params     = @statement.delete(:params)     || {}    # not a great name; it's more like edits/overwrites to the statement
      @vars       = @statement.delete(:vars)       || {}

      @statement.merge! @params
      @vars.symbolize_keys!

      #@statement = clean @statement
      interpret @statement

      self
    end

    def run
      retrn = statement[:return].present? ? statement[:return].to_s : 'card'
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
      if retrn == 'name' && (statement[:prepend] || statement[:append])
        rows.map do |row|
          [ statement[:prepend], row['name'], statement[:append] ].compact * '+'
        end
      else
        case retrn
        when 'count'                 ; rows.first['count'].to_i
        when 'raw'                   ; rows
        when /id$/                   ; rows.map { |row| row[retrn].to_i }
        else                         ; rows.map { |row| row[retrn]      }
        end
      end
    end

    def run_sql
      #puts "statement = #{@statement}"
      #puts "sql = #{sql}"
      ActiveRecord::Base.connection.select_all( sql )
    end

    def sql
      @sql ||= SqlStatement.new( self ).build.to_s
    end

    def root
      @root ||= @superquery ? @superquery.root : self
    end

    def subquery opts={}
      subquery = Query.new opts.reverse_merge(:superquery=>self)
      @subqueries << subquery
      subquery
    end

    def interpret clause
      interpret_by_key( normalize_clause clause )
    end

    def normalize_clause clause
      clause = clause_to_hash clause
      clause.symbolize_keys!
      clause.each do |key,val|
        clause[key] = normalize_value val
      end
      clause
    end

    def clause_to_hash clause
      case clause
      when Hash;     clause
      when String;   { :key => clause.to_name.key }
      when Integer;  { :id => clause }
      else;          raise BadQuery, "Invalid cardclause args #{clause.inspect}"
      end
    end

    def normalize_value val
      case val
      when Integer, Float, Symbol, Hash ; val
      when String, Card::Name           ; normalize_string_value val
      when Array                        ; val.map { |v| normalize_value v }
      else                              ; raise BadQuery, "unknown WQL value type: #{val.class}"
      end
    end

    def normalize_string_value val
      case val.to_s
      when /^\$(\w+)$/                       # replace from @vars
        @vars[$1.to_sym].to_s.strip
      when /\b_/                             # absolutize based on @context
        val.to_name.to_absolute(root.context)
      else
        val
      end
    end

    def interpret_by_key clause
      clause.each do |key,val|
        case
        when OPERATORS.has_key?(key.to_s) && !ATTRIBUTES[key]
          # eg match is both operator and attribute;
          # interpret as attribute when match is key
          interpret content: [key,val]
        when MODIFIERS.has_key?(key) && !clause[key].is_a?(Hash)
          # eg when sort is hash, it can have subqueries
          # and may need to be treated like an attribute
          @mods[key] = Array === val ? val : val.to_s
        when key==:cond
          @conditions << [ key, SqlCond.new(val) ]
        else
          interpret_attributes key, val
        end
      end
    end

    def interpret_attributes key, val
      case ATTRIBUTES[key]
        when :ignore                               #noop
        when :basic                              ; @conditions << [ key, ValueClause.new(val, self) ]
        when :conjunction                        ; send key, val
        when :relational, :special               ; relate key, val
        when :ref_relational                     ; relate key, val, method: :join_references
        when :plus_relational                    ; compound_relate key, val
        else                                     ; raise BadQuery, "Invalid attribute #{key}"
      end
    end

    def compound_relate key, val
      multiple = Array===val && ( Array===val.first || !!conjunction(val.first) )
      relate key, val, multiple: multiple
    end

    def relate key, val, opts={}
      multiple = opts[:multiple].nil? ? Array===val : opts[:multiple]
      method = opts[:method] || :send

      if multiple
        conj = conjunction( val.first ) ? conjunction( val.shift ) : :and
        if conj == current_conjunction                # same conjunction as container, no need for subcondition
          val.each { |v| send method, key, v }
        else
          send conj, val.map { |v| { key => v } }
        end
      else
        send method, key, val
      end
    end

    def current_conjunction
      @mods[:conj].blank? ? :and : @mods[:conj]
    end

  end
end

