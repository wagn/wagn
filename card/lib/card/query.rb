# -*- encoding : utf-8 -*-

class Card::Query
  require_dependency 'card/query/clause'
  require_dependency 'card/query/card_clause'
  require_dependency 'card/query/value_clause'
  require_dependency 'card/query/ref_clause'

  MODIFIERS = {};  %w{ conj return sort sort_as group dir limit offset }.each{|key| MODIFIERS[key.to_sym] = nil }

  OPERATORS = %w{ != = =~ < > in ~ }.inject({}) {|h,v| h[v]=nil; h }.merge({
    :eq    => '=',   :gt => '>',    :lt      => '<',
    :match => '~',   :ne => '!=',   'not in' => nil
  }.stringify_keys)

  def initialize query
    @card_clause = CardClause.build query
  end

  def query
    @card_clause.query
  end

  def sql
    @sql ||= @card_clause.to_sql
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
    ActiveRecord::Base.connection.select_all( sql )
  end


  class SqlCond < String
    def to_sql(*args) self end
  end


  class SqlStatement
    attr_accessor :fields, :tables, :joins, :conditions, :group, :order, :limit, :offset, :distinct

    def initialize
      @fields, @joins, @conditions = [],[],[],[]
      @tables = @group = @order = @limit =  @offset = @distinct = nil
    end

    def to_s
      select = fields.reject(&:blank?) * ', '
      where = conditions.reject(&:blank?) * ' and '

      ['(SELECT', distinct, select, 'FROM', tables, joins, 'WHERE', where, group, order, limit, offset, ')'].compact * ' '
    end
  end


end

