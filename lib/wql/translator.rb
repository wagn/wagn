module Wql
  # FIXME: this should not be hardcoded
  ANON_ROLE_ID = 1 unless defined?(ANON_ROLE_ID)
  AUTH_ROLE_ID = 2 unless defined?(AUTH_ROLE_ID)
  
  class Translator
    attr_accessor :statement, :root_alias, :main_alias_stack, :current_alias,
      :current_relation, :section, :current_clause, :alias_stack, :main_alias_pending, :wql
      
    def initialize( wql )
      self.wql = wql
      self.statement = SqlStatement.new   
      @stack = []
      self.section = 'where'
    end
     
    def main_alias
      @stack.last=='' ?  @stack[-2] : @stack.last
    end
    
    def relation( v )                  
      #warn "MAIN ALIAS2 #{main_alias}"      
      if main_alias
        self.current_relation = v
      else
        raise "Can't begin relationship before main table has been defined"
      end
    end
    
    # to make the sql more readable, {c} is an abbreviation for #{current_alias} and
    # {m} is for #{main_alias}
    def nodetype( v )
      if v.match /pieces/
        statement.post_sql << 'pieces'
      end
      self.current_alias = statement.next_alias
      if !current_relation 
        #warn "DEFINING FIRST RELATION"
        # define the first table
        self.root_alias = self.current_alias  
        @stack << self.root_alias
        #self.main_alias_stack << self.root_alias
        
        #warn "MAIN ALIAS #{main_alias}"
            
        #FIXME: there are two cases for public cards: ANON and null.  could be reduced to one.
        
        root_table = "cards #{root_alias}"
        if System.always_ok?
          statement.tables << root_table
        elsif User.current_user.login=='anon'
          #FIXME: this shouldn't be hardcoded
          statement.tables << root_table
          add_to_statement %{ (
            {r}.reader_id IS NULL 
            OR ({r}.reader_type='Role' and {r}.reader_id=#{ANON_ROLE_ID})
          ) }.substitute!( :r =>root_alias )
        else
          cuid = User.current_user.id
          statement.tables << root_table + " left join roles_users ru on ru.user_id=#{cuid} and ru.role_id=#{root_alias}.reader_id" 
          add_to_statement %{ (             
                ({r}.reader_type='Role' and {r}.reader_id IN (#{ANON_ROLE_ID}, #{AUTH_ROLE_ID}))
             OR ({r}.reader_type='User' and {r}.reader_id=#{cuid})
             OR ({r}.reader_type='Role' and ru.user_id is not null)
          ) }.substitute!( :r =>root_alias )
          statement.pending_group << "ru.user_id"
        end

        statement.fields << "#{root_alias}.*"  
        add_to_statement not_trash(root_alias)
      else                           
        #warn "DEFINIG ADDITIONAL JOINS"        
        # define additional join tables
        case current_relation
            
          when /tags are/
            join_cards "({c}.id = {m}.tag_id)" 
          
          when /trunks are/
            join_cards "{m}.trunk_id = {c}.id"
            
          when /plus/
            join_cards "{m}.trunk_id = {c}.id OR " +  # me + X
              "({c}.id = {m}.tag_id)" # X + me 

          when /trunk connections are/
            join_cards "{c}.trunk_id={m}.id"
            
          when /tag connections are/
            join_cards "{c}.tag_id={m}.id"

          when /^connections are/
            join_cards "{c}.trunk_id={m}.id OR {c}.tag_id={m}.id"

          when /tagged by/
            join_cards "{c}.trunk_id = {m}.id"
            # FIXME - this next_alias thing is confusing:
            # after the next statement {c} will refer to a new table, 
            # while {combo_alias} refers to the table previously referred to by {c}.
            combo_alias,self.current_alias = self.current_alias, statement.next_alias
            join_cards "{c}.id=#{combo_alias}.tag_id"
            
          when /tagging/
            join_cards "{c}.tag_id = {m}.id"
            combo_alias,self.current_alias = self.current_alias, statement.next_alias 
            join_cards "#{combo_alias}.trunk_id= {c}.id"
 
          when /link to/
            join "wiki_references {c} ON {c}.card_id={m}.id"
            wiki_ref_alias, self.current_alias = self.current_alias, statement.next_alias
            join_cards "#{wiki_ref_alias}.referenced_name={c}.name"
            
          when /connected to/  
            #if statement.joins.length > 0 
            #  raise("sorry, can't combine connected to with other relations")
            #end      
            # Not tested for arbitrary combinations of relationships-- uncommented
            # above to get it working for matching, which adds joins     
            #
            # Unfortunately, this 
                                                        
            if statement.condition_set_stack.last.last
              statement.condition_set_stack.last.pop
            end
            #warn "CSS = #{statement.condition_set_stack.inspect}" 
            @slurp_mode = true
            @holding_statement = ""
            @on_finish = :finish_connected_to
            
        end

        # when we hit an open paren we push a new frame on the stack, but main_alias isn't set,
        # so it falls back to the previous stack_frame.  when we hit the first table alias inside 
        # the new context, that gets set and the main_alias inside this context.
        if @stack.last==''
          @stack[-1] = self.current_alias
        end
      end
    end
    
    def finish_connected_to
      wql1 = "cards tagged by cards #{@holding_statement}"
      wql2 = "cards tagging cards #{@holding_statement}"
      @slurp_mode = false
      subsql1 = Parser.new.parse(wql1)
      subsql2 = Parser.new.parse(wql2)
      statement.tables = [ "(#{subsql1} UNION #{subsql2}) as #{root_alias}" ]
      statement.fields = [ "#{root_alias}.*" ]      
                                                                                
      # FIXME  remove the permissions conditions when we're generating nested sql
      # this should be unhacked in later refactoring                                                                                  
      statement.condition_set_stack.last.reject!{ |cond|  cond.match(/reader_id/) }
      #statement.condition_set_stack=[SqlConditionSet.new]  # erase all where entries
    end
    
    def translate( symbol, value )
      #warn "TRANSLATE #{symbol} #{value}"
      if @slurp_mode
        if  [:order, :limit, :eol].include?(symbol)
          @slurp_mode=false
          self.send( @on_finish )
          self.send( symbol, value )
        else
          @holding_statement << "#{value} " if value
        end
      else
        self.send( symbol, value )
      end
    end
    
    def order( v )
      self.section='order'
      self.current_alias = root_alias
    end
    
    def limit( v )
      self.section='limit'
    end
 
    def where( v ) end
    
    def conj( v ) 
      add_to_statement " #{v} " 
    end
   
    def lparen( v )
      statement.nest_condition
      @stack << ''
    end
    
    def rparen( v )
      statement.unnest_condition
      @stack.pop
    end
    
    # the trio of field, op, and literal have an extra twist--
    # when in the 'where' section, we save them into a temporary clause
    # instead of adding to the statement immediately, so that we can
    # perform additional transformations based on the op.
    
    def field( v )   
      #warn "FIELD #{v} current_alias #{current_alias}"
      @current_field = v
      case v
        when "cards_tagged": 
          # FIXME: this is a totallly brittle hack for the tag cloud that will
          # only work for one query
          statement.group += Card::Base.columns.plot(:name).map{|x| "#{main_alias}.#{x}" } + ["t2.type"]
          statement.fields << 't2.type'
          @current_field= "count(*)"
        when "content":      join_for_field 'revisions', '{c}.id={m}.current_revision_id'
        when "revised_at":   join_for_field 'revisions', '{c}.id={m}.current_revision_id'
        when "updated_at":   join_for_field 'revisions', '{c}.id={m}.current_revision_id'  
        when "editors":      join_for_field('revisions', '{c}.card_id={m}.id', 'created_by') do |ca|
          #statement.fields << "#{ca}.created_at as edit_time"
        end 
        when "relevance"
           @current_field = "#{current_alias}.trunk_id is not null, #{current_alias}.name"
           statement.fields << "#{current_alias}.trunk_id is not null"
        else
          @current_field = current_alias + '.' + @current_field
      end
      @current_field.strip!
      if section=='where'
        self.current_clause = [@current_field]
      else
        add_to_statement @current_field
      end
      
    end
    
    def op( v )
      v.strip!
      if section=='where'
        unless ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
          v = "=" if v == "is"
          v = "!=" if v == "is not"
        end
        self.current_clause << v
     else
        add_to_statement v
      end
    end
    
    def literal( v )
      v.strip!
      if section=='where'   
        if ActiveRecord::Base.connection.adapter_name == "SQLite"
          v = "'t'" if v == "true"
          v = "'f'" if v == "false"
        elsif ActiveRecord::Base.connection.adapter_name == "MySQL"
          v = 1 if v == "true"
          v = 0 if v == "false"
        end
        self.current_clause << v
        add_clause( self.current_clause )
      else
        add_to_statement v
      end
    end
    
    def eol( v ) end
    
    def order_mod( v )  add_to_statement " #{v} " end
    def comma( v )      add_to_statement " #{v} " end

    
    private 
      def q(value)
        ActiveRecord::Base.connection.quote(value)
      end
      
      def not_trash(table)
        ActiveRecord::Base.send :sanitize_sql, ["#{table}.trash=?",false]
      end
      
      def join_cards( sql )
        join( "cards {c} ON #{sql} AND " + not_trash('{c}') )
      end
    
      def left_join( sql )
        join( sql, "LEFT JOIN")
      end
      
      def join( sql, join="JOIN" )
        statement.joins << " #{join} " + sql.clone.substitute!( :c =>current_alias, :m=>main_alias, :r=>root_alias )
      end
    
      def join_for_field( table, join, fieldname=nil )
        fieldname ||= @current_field
        old_alias, self.current_alias = self.current_alias, statement.next_alias
        join "#{table} #{current_alias} ON #{join}" 
        statement.fields << "#{current_alias}.#{fieldname} as #{@current_field}"
        yield( current_alias ) if block_given?
        @current_field = current_alias + '.' + fieldname    
        self.current_alias = old_alias 
      end
    
      def add_to_statement( text )  
        #warn "ADD TO STATEMENT #{text}"
        case section
          when 'where'; statement.add_condition( text )
          when 'order'; statement.order << text
          when 'limit'; statement.limit << text
        end
      end
      
      def add_clause( clause )
        field, op, value = clause
        case op
          when 'matching'
            value.gsub!(/^\'|\"/,'')
            value.gsub!(/\'|\"$/,'')
            if value.match /^\s*$/
              value="$"  # HACK
            end
            sql = value.split(/\s+/).map do |x|
              x.gsub!( /(\*|\+|\(|\))/ ) do
                '\\\\' + $~[1]
              end
              "replace(#{field}, '#{JOINT}',' ') #{ActiveRecord::Base.connection.match(q("[[:<:]]" + x + "[[:>:]]"))}"
            end.join(" AND ")
          when '~'
            sql = "#{field} #{ActiveRecord::Base.connection.match(value)}"
          when 'include'
            sql = "#{field} = #{value}"
          else
            sql =  "#{field} #{op} #{value}"
        end
        add_to_statement sql 
      end
      
      #def method_missing( meth, *args )
      #  add_to_statement " " + args[0].to_s + " " 
      #end
      
  end
end