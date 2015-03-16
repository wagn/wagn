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
#    puts "~~~~~~~~~~~~~~\nCARD SPEC =\n#{@card_clause.rawclause}\n\n-----\n\nSQL=\n#{sql}"
    rows = ActiveRecord::Base.connection.select_all( sql )
    retrn = query[:return].present? ? query[:return].to_s : 'card'
    case retrn 
    when 'card'
      rows.map do |row|
        card=
          if query[:prepend] || query[:append]
            cardname = [query[:prepend], row['name'], query[:append]].compact.join('+')
            Card.fetch cardname, :new=>{}
          else
            Card[ row['name'] ]
          end
        card.nil? ? Card.find_by_name_and_trash(row['name'],false).repair_key : card
      end
    when 'count'
      rows.first['count'].to_i
    when 'raw'
      rows
    else
      integer = ( retrn =~ /id$/ )
      rows.map do |row|
        integer ? row[retrn].to_i : row[retrn]
      end
    end
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

