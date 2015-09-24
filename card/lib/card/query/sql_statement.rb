class Card::Query::SqlStatement
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