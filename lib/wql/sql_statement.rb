module Wql
  class SqlStatement
    attr_accessor :fields, :first_alias, :aliases, :tables, 
      :joins, :where, :group, :order, :limit, :post_sql, :condition_set_stack, :pending_group
    def initialize
      self.aliases=[]
      self.tables=[]
      self.fields=[]
      self.joins=[]
      #self.where=[]
      self.condition_set_stack=[SqlConditionSet.new]
      self.order=""
      self.limit=""
      self.group=[]
      self.pending_group=[]
      self.post_sql=[]
    end
    
    def nest_condition
      conditions = SqlConditionSet.new
      add_condition( conditions )
      condition_set_stack.push conditions
    end
    
    def unnest_condition
      condition_set_stack.pop
    end
    
    def add_condition( cond )
      condition_set_stack.last << cond 
    end
    
    def next_alias
      new_alias = 't' + aliases.length.to_s 
      self.first_alias = new_alias if aliases.empty?
      aliases.push( new_alias ).last
    end
    
    def to_s
      string = "SELECT"
      string << " DISTINCT " if group.blank?
      string << " #{fields.join(", ")} FROM #{tables.join(", ")} "
      string << joins.join(" ")  unless joins.empty?   
      
      where = condition_set_stack.first.to_s     
      unless group.empty?
        string << " GROUP BY #{(group+pending_group).join(", ")}"
        string << " HAVING #{where}" unless where.strip.empty?  
      else
        string << " WHERE #{where}"  unless where.strip.empty? 
      end
        
      string << " ORDER BY " + order unless order.strip.empty?
      string << " LIMIT "    + limit.gsub(", ", " OFFSET ") unless limit.strip.empty?
      string
    end
    
    def q(value)
      ActiveRecord::Base.connection.quote(value)
    end
  end
  
  class SqlConditionSet < Array
    def to_s
      bits = self.plot(:to_s).plot(:strip).reject{|x|x.empty?}
      return "" if bits.length == 0
      result = ""
      while bits.length > 0
        result << bits.shift
        if bits[0]
          if bits[0].match( /^(and|or)$/i )
            result << " #{bits.shift} "
          else 
            result << " AND "
          end
        end
      end
      "(#{result})"
    end
  end
end