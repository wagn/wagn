
class Card
  class Query
    class CardClause < Clause
    
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
    
      attr_reader :sql, :query, :rawclause, :selfname
      attr_accessor :joins, :join_count

      class << self
        def build query
          cardclause = self.new query
          cardclause.merge cardclause.rawclause
        end
      end

      def initialize query
        @mods = MODIFIERS.clone
        @clause, @joins = {}, {}
        @selfname, @parent = '', nil
        @sql = SqlStatement.new

        @query = query.clone
        @query.merge! @query.delete(:params) if @query[:params]
        @vars = @query.delete(:vars) || {}
        @vars.symbolize_keys!
        @query = clean(@query)
        @rawclause = @query.deep_clone
        
        @sql.distinct = 'DISTINCT' if @parent

        self
      end


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # QUERY CLEANING - strip strings, absolutize names, interpret contextual parameters
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

      def clean query
        query = query.symbolize_keys
        if s = query.delete(:context) then @selfname = s end
        if p = query.delete(:_parent) then @parent   = p end
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
        @parent ? @parent.root : self
      end
    
      def absolute_name name
        name =~ /\b_/ ? name.to_name.to_absolute(root.selfname) : name
      end


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # MERGE - reduce query to basic attributes and SQL subconditions
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

      def merge s
        s = hashify s
        translate_to_attributes s
        ready_to_sqlize s
        @clause.merge! s
        self
      end
  
      def hashify s
        case s
          when String;   { :key => s.to_name.key }
          when Integer;  { :id => s              }
          when Hash;     s
          else; raise BadQuery, "Invalid cardclause args #{s.inspect}"
        end
      end

      def translate_to_attributes clause
        content = nil
        clause.each do |key,val|
          if key == :_parent
            @parent = clause.delete(key)
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
              when :relational, :special, :conjunction ; relate is_array, keyroot, val, :send
              when :ref_relational                     ; relate is_array, keyroot, val, :refclause
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

      def refclause key, val        
        add_join :ref, RefClause.new( key, val, self ).to_sql, :id, :ref_id
      end


      def conjunction val
        if [String, Symbol].member? val.class
          CONJUNCTIONS[val.to_sym]
        end
      end


      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # ATTRIBUTE METHODS - called during merge
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    

      #~~~~~~ RELATIONAL

      def type val
        restrict :type_id, val
      end

      def part val
        right = Integer===val ? val : val.clone
        subcondition :left=>val, :right=>right, :conj=>:or
      end

      
      def left val
        restrict :left_id, val
      end
    
      def right val
        restrict :right_id, val
      end
      
      def editor_of val
        action_clause :actor_id, "card_actions.card_id", val
      end

      def edited_by val
        action_clause "card_actions.card_id", :actor_id, val
      end
      
      def last_editor_of val
        restrict_by_join :id, val, :return=>'updater_id'
      end

      def last_edited_by val
        restrict :updater_id, val
      end    

      def creator_of val
        restrict_by_join :id, val, :return=>'creator_id'
      end

      def created_by val
        restrict :creator_id, val
      end

      def member_of val
        merge field(:right_plus) => [RolesID, {:refer_to=>val}]
      end
  
      def member val
        merge field(:referred_to_by) => {:left=>val, :right=>RolesID }
      end


      #~~~~~~ PLUS RELATIONAL

      def left_plus val
        junction :left, val
      end

      def right_plus val
        junction :right, val
      end

      def plus val
        any( { :left_plus=>val, :right_plus=>val.deep_clone } )
      end
      
      def junction side, val
        part_clause, junction_clause = val.is_a?(Array) ? val : [ val, {} ]
        restrict_by_join :id, junction_clause, side=>part_clause, :return=>"#{ side==:left ? :right : :left}_id"
      end
    
    
      #~~~~~~~  CONJUNCTION
    
      def and val
        subcondition val
      end
      alias :all :and
  
      def or val
        subcondition val, :conj=>:or
      end
      alias :any :or
    
      #~~~~~~ SPECIAL


      def found_by val
      
        cards = if Hash===val
          Query.new(val).run
        else
          Array.wrap(val).map do |v|
            Card.fetch absolute_name(val), :new=>{}
          end
        end

        cards.each do |c|
          unless c && [SearchTypeID,SetID].include?(c.type_id)
            raise BadQuery, %{"found_by" value needs to be valid Search, but #{c.name} is a #{c.type_name}}
          end
          restrict_by_join :id, CardClause.new(c.get_query).rawclause
        end
      end
  
      def not val
        subselect = CardClause.build(:return=>:id, :_parent=>self).merge(val).to_sql
        join_alias = add_join :not, subselect, :id, :id, :side=>'LEFT'        
        merge field(:cond) => SqlCond.new("#{join_alias}.id is null")
      end

      def sort val
        return nil if @parent
        val[:return] = val[:return] ? safe_sql(val[:return]) : 'db_content'
        item = val.delete(:item) || 'left'

        if val[:return] == 'count'
          cs_args = { :return=>'count', :group=>'sort_join_field', :_parent=>self }
          @mods[:sort] = "coalesce(count,0)" # needed for postgres
          case item
          when 'referred_to'
            join_field = 'id'
            cs = CardClause.build cs_args.merge( field(:cond)=>SqlCond.new("referer_id in #{CardClause.build( val.merge(:return=>'id')).to_sql}") )
            cs.add_join :wr, :card_references, :id, :referee_id
          else
            raise BadQuery, "count with item: #{item} not yet implemented"
          end
        else
          join_field = case item
            when 'left'  ; 'left_id'
            when 'right' ; 'right_id'
            else         ;  raise BadQuery, "sort item: #{item} not yet implemented"
          end
          cs = CardClause.build(val)
        end

        cs.sql.fields << "#{cs.table_alias}.#{join_field} as sort_join_field"
        join_table = add_join :sort, cs.to_sql, :id, :sort_join_field, :side=>'LEFT'
        @mods[:sort] ||= "#{join_table}.#{val[:return]}"
        
      end

      def match(val)
        cxn, val = match_prep val
        val.gsub! /[^#{Card::Name::OK4KEY_RE}]+/, ' '
        return nil if val.strip.empty?
    

        cond = begin
          val_list = val.split(/\s+/).map do |v|
            name_or_content = ["replace(#{self.table_alias}.name,'+',' ')","#{self.table_alias}.db_content"].map do |field| 
              %{#{field} #{ cxn.match quote("[[:<:]]#{v}[[:>:]]") }}
            end
            "(#{name_or_content.join ' OR '})"
          end
          "(#{val_list.join ' AND '})"
        end

        merge field(:cond)=>SqlCond.new(cond)
      end
    
    
      def complete(val)
        no_plus_card = (val=~/\+/ ? '' : "and right_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
        merge field(:cond) => SqlCond.new(" lower(name) LIKE lower(#{quote(val.to_s+'%')}) #{no_plus_card}")
      end

      def extension_type val
        # DEPRECATED LONG AGO!!!
        Rails.logger.info "using DEPRECATED extension_type in WQL" 
        merge field(:right_plus) => AccountID
      end
    

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # ATTRIBUTE METHOD HELPERS - called by attribute methods above
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


      def table_alias
        case
        when @mods[:return]=='condition'
          @parent ? @parent.table_alias : "t"
        when @parent
          @parent.table_alias + "x"
        else 
          "t"
        end
      end

      def add_join(name, table, cardfield, otherfield, opts={})
        root.join_count = root.join_count.to_i + 1
        join_alias = "#{name}_#{root.join_count}"
        on = "#{table_alias}.#{cardfield} = #{join_alias}.#{otherfield}"
        #is_subselect = !table.is_a?( Symbol )
        
        if @mods[:conj] == 'or'  #and is_subselect
          opts[:side] ||= 'LEFT'
          merge field(:cond) => SqlCond.new(on)
        end
        @joins[join_alias] = ["\n  ", opts[:side], 'JOIN', table, 'AS', join_alias, 'ON', on, "\n"].compact.join ' '
        join_alias
      end

      def field name
        @fields ||= {}
        @fields[name] ||= 0
        @fields[name] += 1
        "#{ name }_#{ @fields[name] }"
      end

      def field_root key
        key.to_s.gsub /\_\d+/, ''
      end

      def subcondition(val, args={})
        args = { :return=>:condition, :_parent=>self }.merge(args)
        cardclause = CardClause.build( args )
        merge field(:cond) => cardclause.merge(val)
        self.joins.merge! cardclause.joins
      end      
      
      def action_clause(field, linkfield, val)
        card_select = CardClause.build(:_parent=>self, :return=>'id').merge(val).to_sql
        sql =  "(SELECT DISTINCT #{field} AS join_card_id FROM card_acts INNER JOIN card_actions ON card_acts.id = card_act_id "
        sql += " JOIN (#{card_select}) AS ss ON #{linkfield}=ss.id AND (draft is not true))"
        add_join :ac, sql, :id, :join_card_id
      end

      def id_from_clause clause
        case clause
        when Integer ; clause
        when String  ; Card.fetch_id(clause)
        end
      end
            
      def restrict id_field, val, opts={}
        if id = id_from_clause(val)
          merge field(id_field) => id
        else
          restrict_by_join id_field, val, opts
        end
      end
      
      def restrict_by_join id_field, val, opts={}
        opts.reverse_merge!(:return=>:id, :_parent=>self)
        subselect = CardClause.build(opts).merge(val).to_sql
        add_join "card_#{id_field}", subselect, id_field, opts[:return]
      end
    
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # SQL GENERATION - translate merged hash into complete SQL statement.
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


      def to_sql *args
        sql.conditions << basic_conditions
        
        if @mods[:return]=='condition'
          conds = sql.conditions.last
          return conds.blank? ? nil : "(#{conds})"
        end
    
        if pconds = permission_conditions
          sql.conditions << pconds
        end

        sql.fields.unshift fields_to_sql
        sql.order = sort_to_sql  # has side effects!
        sql.tables = "cards #{table_alias}"
        sql.joins += @joins.values

        sql.conditions << "#{table_alias}.trash is false"
      
        sql.group = "GROUP BY #{safe_sql(@mods[:group])}" if !@mods[:group].blank?
        unless @parent or @mods[:return]=='count'
          if @mods[:limit].to_i > 0
            sql.limit  = "LIMIT #{  @mods[:limit ].to_i }"
            sql.offset = "OFFSET #{ @mods[:offset].to_i }" if !@mods[:offset].blank?
          end
        end

        sql.to_s
      end
  
      def basic_conditions
        @clause.map { |key, val| val.to_sql field_root(key) }.compact.join " #{ current_conjunction } "
      end
  
      def current_conjunction
        @mods[:conj].blank? ? :and : @mods[:conj]
      end
    
      def permission_conditions
        unless Auth.always_ok? #or ( Card::Query.root_perms_only && !root? )
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
    
        return nil if @parent or @mods[:return]=='count' #FIXME - extend to all root-only clauses
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
        "#{order_field} #{dir}"
    
      end
    end
  end
end
