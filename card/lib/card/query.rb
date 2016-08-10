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
    require_dependency "card/query/clause"
    require_dependency "card/query/value"
    require_dependency "card/query/reference"
    require_dependency "card/query/attributes"
    require_dependency "card/query/sql_statement"
    require_dependency "card/query/join"

    include Clause
    include Attributes
    include RelationalAttributes
    include Interpretation
    include Sorting
    include Conjunctions
    include Helpers

    ATTRIBUTES = {
      basic:           %w( id name key type_id content left_id right_id
                           creator_id updater_id codename read_rule_id        ),
      relational:      %w( type part left right
                           editor_of edited_by last_editor_of last_edited_by
                           creator_of created_by member_of member             ),
      plus_relational: %w(plus left_plus right_plus),
      ref_relational:  %w( refer_to referred_to_by
                           link_to linked_to_by
                           include included_by                                ),
      conjunction:     %w(and or all any),
      special:         %w(found_by not sort match complete extension_type),
      ignore:          %w(prepend append view params vars size)
    }.each_with_object({}) do |pair, h|
      pair[1].each { |v| h[v.to_sym] = pair[0] }
    end

    CONJUNCTIONS = { any: :or, in: :or, or: :or, all: :and, and: :and }.freeze

    MODIFIERS = %w(conj return sort sort_as group dir limit offset)
                .each_with_object({}) { |v, h| h[v.to_sym] = nil }

    OPERATORS =
      %w(!= = =~ < > in ~).each_with_object({}) { |v, h| h[v] = v }.merge(
        {
          eq: "=", gt: ">", lt: "<", match: "~", ne: "!=", "not in" => nil
        }.stringify_keys
      )

    DEFAULT_ORDER_DIRS = { update: "desc", relevance: "desc" }.freeze

    attr_reader :statement, :mods, :conditions, :comment,
                :subqueries, :superquery
    attr_accessor :joins, :table_seq, :unjoined, :conditions_on_join

    # Query Execution

    # By default a query returns card objects. This is accomplished by returning
    # a card identifier from SQL and then hooking into our caching system (see
    # Card::Fetch)

    def self.run statement, comment=nil
      new(statement, comment).run
    end

    def initialize statement, comment=nil
      @subqueries = []
      @conditions = []
      @joins = []
      @mods = {}
      @statement = statement.clone

      @context    = @statement.delete(:context) || nil
      @unjoined   = @statement.delete(:unjoined) || nil
      @superquery = @statement.delete(:superquery) || nil
      @vars       = @statement.delete(:vars) || {}
      @vars.symbolize_keys!

      @comment = comment || default_comment

      interpret @statement
      self
    end

    def default_comment
      return if @superquery || !Card.config.sql_comments
      statement.to_s
    end

    # run the current query
    # @return array of card objects by default
    def run
      retrn = statement[:return].present? ? statement[:return].to_s : "card"
      if retrn == "card"
        get_results("name").map do |name|
          Card.fetch name, new: {}
        end
      else
        get_results retrn
      end
    end

    # @return Integer for :count, otherwise Array of Strings or Integers
    def get_results retrn
      rows = run_sql
      if retrn == "name" && (statement[:prepend] || statement[:append])
        rows.map do |row|
          [statement[:prepend], row["name"], statement[:append]].compact * "+"
        end
      else
        case retrn
        when "count" then rows.first["count"].to_i
        when "raw"   then rows
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

    def context
      if !@context.nil?
        @context
      else
        @context = @superquery ? @superquery.context : ""
      end
    end
  end
end
