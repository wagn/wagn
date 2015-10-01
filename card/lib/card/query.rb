# -*- encoding : utf-8 -*-

class Card
  # Card::Query is for finding implicit lists (or counts of lists) of cards.
  #
  # Search and Set cards use Card::Query to query the database, and it's also
  # frequently used directly in code.
  #
  # Query "statements" (objects, really) are made in WQL (Wagn Query
  # Language). Because WQL is used by Wagneers, the primary language
  # documentation is on wagn.org. (http://wagn.org/WQL_Syntax). Note that the
  # examples there are in JSON, like Search card content, but statements in
  # Card::Query are in ruby form.
  #
  # In Wagn's current form, Card::Query generates and executes SQL statements.
  # However, the SQL generation is largely (not yet fully) separated from the
  # WQL statement interpretation.
  #
  # The most common way to use Card::Query is as follows:
  #     list_of_cards = Card::Query.run(statement)
  #
  # This is equivalent to:
  #     query = Card::Query.new(statement)
  #     list_of_cards = query.run
  #
  # Upon initiation, the query is interpreted, and the following key objects
  # are populated:
  #
  # - @join - an Array of Card::Query::Join objects
  # - @conditions - an Array of conditions
  # - @mod - a Hash of other query-altering keys
  # - @subqueries - a list of other queries nested within this one
  #
  # Each condition is either a SQL-ready string (boo) or an Array in this form:
  #    [ field_string_or_sym, Card::Value::Query object ]
  class Query
    require_dependency 'card/query/clause'
    require_dependency 'card/query/value'
    require_dependency 'card/query/reference'
    require_dependency 'card/query/attributes'
    require_dependency 'card/query/sql_statement'
    require_dependency 'card/query/join'

    include Clause
    include Attributes

    ATTRIBUTES = {
      basic:           %w( id name key type_id content left_id right_id
                           creator_id updater_id codename                     ),
      relational:      %w( type part left right
                           editor_of edited_by last_editor_of last_edited_by
                           creator_of created_by member_of member             ),
      plus_relational: %w( plus left_plus right_plus                          ),
      ref_relational:  %w( refer_to referred_to_by
                           link_to linked_to_by
                           include included_by                                ),
      conjunction:     %w( and or all any                                     ),
      special:         %w( found_by not sort match complete extension_type    ),
      ignore:          %w( prepend append view params vars size )
    }.inject({}) {|h,pair| pair[1].each { |v| h[v.to_sym]=pair[0] }; h }

    CONJUNCTIONS = { any: :or, in: :or, or: :or, all: :and, and: :and }

    MODIFIERS = %w( conj return sort sort_as group dir limit offset )
      .inject({}) { |h,v| h[v.to_sym]=nil; h }

    OPERATORS = %w( != = =~ < > in ~ ).inject({}) {|h,v| h[v]=v; h }.merge({
      eq: '=', gt: '>', lt: '<', match: '~', ne: '!=', :'not in'=> nil
    }.stringify_keys)

    DEFAULT_ORDER_DIRS =  { :update => "desc", :relevance => "desc" }

    attr_reader :statement, :mods, :conditions,
      :subqueries, :superquery
    attr_accessor :joins, :table_seq, :unjoined, :conditions_bucket

    def initialize statement
      @subqueries = []
      @conditions = []
      @joins = []
      @mods = {}
      @statement = statement.clone

      @unjoined   = @statement.delete(:unjoined  ) || nil
      @context    = @statement.delete(:context   ) || nil
      @superquery = @statement.delete(:superquery) || nil
      @vars       = @statement.delete(:vars      ) || {}
      @vars.symbolize_keys!

      interpret @statement
      self
    end

    # Query Execution
    # By default a query returns card objects. This is accomplished by returning
    # a card identifier from SQL and then hooking into our caching system (see
    # Card::Fetch)

    def self.run statement
      query = new statement
      query.run
    end

    # run the current query
    # @return array of card objects by default
    def run
      retrn = statement[:return].present? ? statement[:return].to_s : 'card'
      if retrn == 'card'
        get_results('name').map do |name|
          Card.fetch name, new: {}
        end
      else
        get_results retrn
      end
    end

    # @return Integer for :count, otherwise Array of Strings or Integers
    def get_results retrn
      rows = run_sql
      if retrn == 'name' && (statement[:prepend] || statement[:append])
        rows.map do |row|
          [statement[:prepend], row['name'], statement[:append]].compact * '+'
        end
      else
        case retrn
        when 'count' then rows.first['count'].to_i
        when 'raw'   then rows
        when /id$/   then rows.map { |row| row[retrn].to_i }
        else              rows.map { |row| row[retrn]      }
        end
      end
    end

    def run_sql
      # puts "\nstatement = #{@statement}"
      # puts "sql = #{sql}"
      ActiveRecord::Base.connection.select_all(sql)
    end

    def sql
      @sql ||= SqlStatement.new(self).build.to_s
    end

    # Query Hierarchy
    # @root, @subqueries, and @superquery are used to track a hierarchy of
    # query objects.  This nesting allows to find, for example, cards that
    # link to cards that link to cards....

    def root
      @root ||= @superquery ? @superquery.root : self
    end

    def subquery opts={}
      subquery = Query.new opts.merge(superquery: self)
      @subqueries << subquery
      subquery
    end

    # Query Interpretation

    # normalize and extract meaning from a clause
    # @param clause [Hash, String, Integer] statement or chunk thereof
    def interpret clause
      interpret_by_key normalize_clause(clause)
    end

    def normalize_clause clause
      clause = clause_to_hash clause
      clause.symbolize_keys!
      clause.each do |key, val|
        clause[key] = normalize_value val
      end
      clause
    end

    def clause_to_hash clause
      case clause
      when Hash    then clause
      when String  then { key: clause.to_name.key }
      when Integer then { id: clause }
      else fail BadQuery, "Invalid query args #{clause.inspect}"
      end
    end

    def normalize_value val
      case val
      when Integer, Float, Symbol, Hash then val
      when String, Card::Name           then normalize_string_value val
      when Array                        then val.map { |v| normalize_value v }
      else fail BadQuery, "unknown WQL value type: #{val.class}"
      end
    end

    def normalize_string_value val
      case val.to_s
      when /^\$(\w+)$/                       # replace from @vars
        @vars[Regexp.last_match[1].to_sym].to_s.strip
      when /\b_/                             # absolutize based on @context
        val.to_name.to_absolute(context)
      else
        val
      end
    end

    def context
      if !@context.nil?
        @context
      else
        @context = @superquery ? @superquery.context : ''
      end
    end

    def interpret_by_key clause
      clause.each do |key, val|
        case
        when OPERATORS.key?(key.to_s) && !ATTRIBUTES[key]
          # eg "match" is both operator and attribute;
          # interpret as attribute when "match" is key
          interpret content: [key, val]
        when MODIFIERS.key?(key) && !clause[key].is_a?(Hash)
          # eg when "sort" is hash, it can have subqueries
          # and must be interpreted like an attribute
          @mods[key] = val.is_a?(Array) ? val : val.to_s
        else
          interpret_attributes key, val
        end
      end
    end

    def add_condition *args
      @conditions <<
        if args.size > 1
          [args.shift, Value.new(args.shift, self)]
        else
          args[0]
        end
    end

    def interpret_attributes key, val
      case ATTRIBUTES[key]
      when :basic            then add_condition key, val
      when :conjunction      then send key, val
      when :relational       then relate key, val
      when :special          then relate key, val
      when :ref_relational   then relate key, val, method: :join_references
      when :plus_relational  then relate_compound key, val
      when :ignore           then # noop
      else                   fail BadQuery, "Invalid attribute #{key}"
      end
    end

    def relate_compound key, val
      has_multiple_values =
        val.is_a?(Array) &&
        (val.first.is_a?(Array) || conjunction(val.first).present?)
      relate key, val, multiple: has_multiple_values
    end

    def relate key, val, opts={}
      multiple = opts[:multiple].nil? ? val.is_a?(Array) : opts[:multiple]
      method = opts[:method] || :send

      if multiple
        conj = conjunction(val.first) ? conjunction(val.shift) : :and
        if conj == current_conjunction
          # same conjunction as container, no need for subcondition
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

    def all_joins
      @all_joins ||=
        (joins + subqueries.find_all(&:unjoined).map(&:all_joins)).flatten
    end
  end
end
