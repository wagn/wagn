module Wql
  class Parser
    attr_accessor :cursym, :curval, :wql, :stream, :debug, :state, :translator
    cattr_accessor :patterns, :field_pattern
           

    def parse( wql )
      self.wql = wql
      self.translator = Translator.new( wql.clone )
      getsym()
      node()
      order() if accept(:order)
      limit() if accept(:limit)
      expect(:eol)
      translator.statement
    end
    self.field_pattern = '(id|id|tag_id|trunk_id|priority|type|name|value|content|created_at|updated_at|revised_at|plus_sidebar|datatype|cards_tagged|editors|edit_time|relevance)'
    self.patterns = [                                     
      :field    ,/^#{self.field_pattern}/,
      :nodetype ,/^(cards|pieces of cards)/,                          
      :op       ,/^(>|<|=|<>|~|is not|is|matching|include)/,                     
      :relation ,/^(link to|tagged\s+by|tagging|plus|trunk connections are|tag connections are|connections are|tags are|trunks are|connected to)/,            
      :literal  ,/^(\"[^\"]*\"|\'[^\']*\'|\d+|null|true|false)/,      
      :eol      ,/^$/,                                
      :conj     ,/^(and|or)\s+/,                         
      :where     ,/^(where|with|that)/,                           
      :lparen   ,/^(\()/,                             
      :rparen   ,/^(\))/,
      :order    ,/^(order by)/,
      :order_mod,/^(asc|desc)/,
      :limit    ,/^(limit)/,
      :comma    ,/^(\,)/
    ]
    
    def getsym()
      patterns.each_slice(2) do |sym, pattern|
        return true if match( pattern, sym )
      end
      raise "wql syntax error near '#{wql}'"
    end
    
    def match( pattern, sym )
      self.wql.strip!
      if m = wql.match( pattern )
        self.wql = m.post_match
        self.cursym = sym
        self.curval = m[1]
        warn "SYM( #{state} ): #{cursym}\t#{curval}" if debug
        return true
      end
      false
    end
    
    def accept( symbol)
      if cursym == symbol then
        translator.translate( cursym, curval )
        getsym()
        return true
      end
      return false
    end
    
    def expect( symbol ) 
      if accept(symbol) 
        return true
      end
      raise "wql parse error: got #{cursym} expected #{symbol} near '#{wql}' \n#{translator.wql}"
    end
    
    def node( relationship=nil )
      expect(:nodetype)
      if accept(:where) or cursym==:relation
        expr()
      end
    end
      
    def expr()
      begin
        cond()
      end while accept(:conj)
    end
    
    def cond()
      case 
        when accept(:relation)
          node()
        when accept(:field)
          expect(:op)
          expect(:literal)
        when accept(:lparen)
          expr()
          expect(:rparen)
      end
    end 

    def order()
      begin
        accept(:field)
        accept(:order_mod)
      end while accept(:comma)
    end
    
    def limit()
      accept(:literal)
      if accept(:comma)
        expect(:literal)
      end
    end
  end
end