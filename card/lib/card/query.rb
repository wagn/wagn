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


    PLUS_ATTRIBUTES = %w{ plus left_plus right_plus }

    ATTRIBUTES = {
      :basic           => %w{ name type_id content id key updater_id left_id right_id creator_id updater_id codename },
      :relational      => %w{ type part left right editor_of edited_by last_editor_of last_edited_by creator_of created_by member_of member },
      :plus_relational => PLUS_ATTRIBUTES,
      :ref_relational  => %w{ refer_to referred_to_by link_to linked_to_by include included_by },
      :conjunction     => %w{ and or all any },
      :special         => %w{ found_by not sort match complete extension_type },
      :ignore          => %w{ prepend append view params vars size }
    }.inject({}) {|h,pair| pair[1].each {|v| h[v.to_sym]=pair[0] }; h }

    DEFAULT_ORDER_DIRS =  { :update => "desc", :relevance => "desc" }
    CONJUNCTIONS = { :any=>:or, :in=>:or, :or=>:or, :all=>:and, :and=>:and }

    attr_reader :query, :selfname, :mods, :conditions, :subqueries, :super
    attr_accessor :joins, :table_seq

    def initialize query
      @conditions, @joins = {}, {}
      @selfname, @super = '', nil
      @subqueries = []

      @mods = MODIFIERS.clone
      @query = query.clone

      @query.merge! @query.delete(:params) if @query[:params]
      @vars = @query.delete(:vars) || {}
      @vars.symbolize_keys!

      @query = clean @query
      interpret @query.deep_clone

      self
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

#      puts "query = #{@query}"
#      puts "sql = #{sql}"
      ActiveRecord::Base.connection.select_all( sql )
    end

    def sql
      @sql ||= SqlStatement.new( self ).build.to_s
    end


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # QUERY CLEANING - strip strings, absolutize names, replace contextual parameters
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    def clean query
      query = query.symbolize_keys
      if s = query.delete(:context) then @selfname = s end
      if p = query.delete(:_super)  then @super    = p end
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
      @super ? @super.root : self
    end


    def subquery opts={}
      subquery = Query.new opts.reverse_merge(:_super=>self)
      @subqueries << subquery
      subquery
    end

    def absolute_name name
      name =~ /\b_/ ? name.to_name.to_absolute(root.selfname) : name
    end


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # MERGE - reduce query to basic attributes and SQL subconditions
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    def interpret s
      s = normalize s
      translate_to_attributes s
      ready_to_sqlize s
      @conditions.merge! s
      self
    end

    def normalize s
      case s
        when Hash;     s
        when String;   { :key => s.to_name.key }
        when Integer;  { :id => s              }
        else;          raise BadQuery, "Invalid cardclause args #{s.inspect}"
      end
    end

    def translate_to_attributes clause
      content = nil
      clause.each do |key,val|
        if key == :_super
          @super = clause.delete(key)
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
            when :conjunction                        ; send keyroot, val
            when :relational, :special               ; relate is_array, keyroot, val, :send
            when :ref_relational                     ; relate is_array, keyroot, val, :join_references
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


    def current_conjunction
      @mods[:conj].blank? ? :and : @mods[:conj]
    end


  end
end

