class Wql
  ATTRIBUTES = {
    :basic      =>  %w{ name type content id key extension_type extension_id updated_by trunk_id tag_id },
    :custom     =>  %w{ edited_by editor_of edited last_editor_of last_edited_by creator_of created_by } +
                    %w{ member_of member role found_by part left right plus left_plus right_plus } + 
                    %w{ or match complete not and sort },
    :referential => %w{ link_to linked_to_by refer_to referred_to_by include included_by },
    :ignore      => %w{ prepend append view }
  }.inject({}) {|h,pair| pair[1].each {|v| h[v.to_sym]=pair[0] }; h }

  MODIFIERS = {};  %w{ conj return sort sort_as group dir limit offset }.each{|key| MODIFIERS[key.to_sym] = nil }

  OPERATORS = %w{ != = =~ < > in ~ }.inject({}) {|h,v| h[v]=nil; h }.merge({
    :eq    => '=',   :gt => '>',    :lt      => '<', 
    :match => '~',   :ne => '!=',   'not in' => nil
  }.stringify_keys)

  DEFAULT_ORDER_DIRS =  { :update => "desc", :relevance => "desc" }

  cattr_reader :root_perms_only
  @@root_perms_only = false

  def self.without_nested_permissions
    @@root_perms_only = true
    result = yield
    @@root_perms_only = false
    result
  end
    
  def initialize( query )  @cs = CardSpec.build( query )  end
  def query()              @cs.query                      end
  def sql()                @sql ||= @cs.to_sql            end
  
  def run
      rows = ActiveRecord::Base.connection.select_all( sql )
    case (query[:return] || :card).to_sym
    when :card
      rows.map do |row|
        card=
          if query[:prepend] || query[:append]
            cardname = [query[:prepend], row['name'], query[:append]].compact.join('+')
            Card.fetch_or_new cardname
          else
            Card[ row['name'] ]
          end
        card.nil? ? Card.find_by_name_and_trash(row['name'],false).repair_key : card
      end
    when :count;    rows.first['count'].to_i
    else;           rows.map { |row| row[query[:return].to_s] }
    end
  end  
  
  
  class Spec 
    attr_accessor :spec
    
    def walk(spec, method)
      case 
        when spec.respond_to?(method); spec.send(method)
        when spec.is_a?(Hash); spec.inject({}) {|h,p| h[p[0]] = walk(p[1], method); h }
        when spec.is_a?(Array); spec.collect {|v| walk(v, method) }
        else spec
      end
    end
    
    def safe_sql(txt)
      txt = txt.to_s
      txt.match( /[^\w\*\(\)\s\.\,]/ ) ? raise( "WQL contains disallowed characters: #{txt}" ) : txt
    end
    
    def quote(v)  ActiveRecord::Base.connection.quote(v)  end
    
    def match_prep(v,cardspec=self)
      cxn ||= ActiveRecord::Base.connection
      v=cardspec.root.params['_keyword'] if v=='_keyword' 
      v.strip!#FIXME - breaks if v is nil
      [cxn, v]
    end
    
    def cast_type(type)
      cxn ||= ActiveRecord::Base.connection
      (val = cxn.cast_types[type.to_sym]) ? val[:name] : safe_sql(type)
    end
  end
  
  
  class SqlCond < String
    def to_sql(*args) self end
  end
  
  
  class SqlStatement
    attr_accessor :fields, :relevance_fields, :tables, :joins,
      :conditions, :group, :order, :limit, :offset
    
    def initialize
      @fields, @relevance_fields, @joins, @conditions = [],[],[],[]
      @tables, @group, @order, @limit, @offset = "","","","",""
    end
    
    def to_s
      "(select #{fields.reject(&:blank?).join(', ')} from #{tables} #{joins.join(' ')} " + 
        "where #{conditions.reject(&:blank?).join(' and ')} #{group} #{order} #{limit} #{offset})"
    end
  end

  class CardSpec < Spec 
    attr_reader :params, :sql, :query, :rawspec
    attr_accessor :joins
    
    class << self
      def build(query)
        cardspec = self.new(query)
        cardspec.merge(cardspec.rawspec)         
      end
    end 
     
    def initialize(query)   
      # NOTE:  when creating new specs, make sure to specify _parent *before*
      #  any spec which could trigger another cardspec creation further down.
      @mods = MODIFIERS.clone
      @params = {}
      @joins = {}   
      @selfname, @parent = nil, nil
      @query = clean(query.clone)
      @rawspec = @query.deep_clone
      @spec = {}
      @sql = SqlStatement.new
      self
    end
    
    def table_alias 
      case
        when @mods[:return]=='condition';   @parent ? @parent.table_alias : "t"
        when @parent; @parent.table_alias + "x" 
        else "t"  
      end
    end
    
    def root()      @parent ? @parent.root : self  end
    def root?()     root == self                   end
    def selfname()  @selfname                      end
    
    def absolute_name(name)
      name = (root.selfname ? name.to_cardname.to_absolute(root.selfname) : name)
    end
    
    def clean(query)
      query = query.symbolize_keys
      query.each do |key,val|
        case key.to_s
        when 'context'  ; @selfname         = query.delete(key)
        when '_parent'  ; @parent           = query.delete(key)   
        when /^_\w+$/   ; @params[key.to_s] = query.delete(key)
        end
      end
      query.each{ |key,val| clean_val(val, query, key) } #must be separate loop to make sure card values are set
      query
    end
    
    
    def clean_val(val, query, key)
      query[key] =
        case val
        when String ; val.empty? ? val : absolute_name(val)
        when Hash   ; clean(val)
        when Array  ; val.map{ |v| clean_val(v, query, key)}
        else        ; val
        end
    end
    
    def merge(spec)
#      spec = spec.clone
      spec = case spec
        when String;   { :key => spec.to_cardname.to_key }
        when Integer;  { :id  => spec                    }  
        when Hash;     spec
        else raise("Invalid cardspec args #{spec.inspect}")
      end

      content = nil
      spec.each do |key,val| 
        if key == :_parent
          @parent = spec.delete(key) 
        elsif OPERATORS.has_key?(key.to_s) && !ATTRIBUTES[key]
          spec.delete(key)
          content = [key,val]
        elsif MODIFIERS.has_key?(key)
          next if spec[key].is_a? Hash
          @mods[key] = spec.delete(key).to_s
        end
      end
      spec[:content] = content if content
      
      spec.each do |key,val| 
        case ATTRIBUTES[key]
          when :basic; spec[key] = ValueSpec.new(val, self)
          when :custom; self.send(key, spec.delete(key))    
          when :referential;  self.refspec(key, spec.delete(key))
          when :ignore; spec.delete(key)
          else raise("Invalid attribute #{key}") unless key.to_s.match(/(type|id|by|cond)\:\d+/)
        end                      
      end
      
      @spec.merge! spec
      self
    end
    
    def add_join(name, table, cardfield, otherfield, opts={})
      join_alias = "#{table_alias}_#{name}"
      @joins[join_alias] = "#{opts[:side]} JOIN #{table} AS #{join_alias} ON #{table_alias}.#{cardfield} = #{join_alias}.#{otherfield}"
      join_alias
    end
    
    def add_revision_join
      add_join(:rev, :revisions, :current_revision_id, :id)
    end
    
    def field(name)
      @fields||={}; @fields[name]||=0; @fields[name]+=1
      "#{name}:#{@fields[name]}"
    end
    
    def found_by(val)
      cards = (String===val ? [Card.fetch_or_new(absolute_name(val))] : Wql.new(val).run)
      cards.each do |c|
        raise %{"found_by" value needs to be valid Search card #{c.inspect}} unless c && ['Search','Set'].include?(c.typecode)
        found_by_spec = CardSpec.new(c.get_spec).rawspec
        merge(field(:id) => subspec(found_by_spec))
      end
    end
    
    def match(val)
      cxn, v = match_prep(val)
      v.gsub!(/\W+/,' ')
      
      cond =
        if System.enable_postgres_fulltext
          v = v.strip.gsub(/\s+/, '&')
          sql.relevance_fields << "rank(indexed_name, to_tsquery(#{quote(v)}), 1) AS name_rank"
          sql.relevance_fields << "rank(indexed_content, to_tsquery(#{quote(v)}), 1) AS content_rank"
          "indexed_content @@ to_tsquery(#{quote(v)})" 
        else
          join_alias = add_revision_join
          # FIXME: OMFG this is ugly
          '(' + ["replace(#{self.table_alias}.name,'+',' ')","#{join_alias}.content"].collect do |f|
            v.split(/\s+/).map{ |x| %{#{f} #{cxn.match(quote("[[:<:]]#{x}[[:>:]]"))}} }.join(" AND ")
          end.join(" OR ") + ')'
        end
      merge field(:cond)=>SqlCond.new(cond)
    end
    
    def complete(val)
      no_plus_card = (val=~/\+/ ? '' : "and tag_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
      merge field(:cond) => SqlCond.new(" lower(name) LIKE lower(#{quote(val.to_s+'%')}) #{no_plus_card}")
    end
    
    def cond(val)                                                                 end #noop
    def and(val)   subcondition(val)                                              end
    def or(val)    subcondition(val, :conj=>:or)                                  end
    def left(val)  merge field(:trunk_id) => subspec(val)                         end
    def right(val) merge field(:tag_id  ) => subspec(val)                         end
    def not(val)   merge field(:id) => subspec(val, {:return=>'id'}, negate=true) end
    
    def part(val) 
      subcondition({ :left => val, :right => val.clone }, :conj=>:or)
    end  

    def left_plus(val)
      part_spec, junc_spec = val.is_a?(Array) ? val : [ val, {} ]
      merge( field(:id) => subspec(junc_spec, :return=>'tag_id', :left =>part_spec))      
    end    
    
    def right_plus(val) 
      part_spec, junc_spec = val.is_a?(Array) ? val : [ val, {} ]
      merge( field(:id) => subspec(junc_spec, :return=>'trunk_id', :right=> part_spec ))
    end                                                                                                
    
    def plus(val)
      part_spec, junc_spec = val.is_a?(Array) ? val : [ val, {} ]
      subcondition({ 
        field(:id) => subspec(junc_spec.deep_clone, :return=>'trunk_id', :right=>part_spec.deep_clone),
        field(:id) => subspec(junc_spec,            :return=>'tag_id',   :left=>part_spec)
      }, :conj=>:or)
    end          
    
    def edited_by(val)
      extension_select = CardSpec.build(:return=>'extension_id', :extension_type=>'User', :_parent=>self).merge(val).to_sql
      add_join :ed_by, "(select distinct card_id from revisions where created_by in #{extension_select} )", :id, :card_id
    end
    
    def created_by(val)
      extension_select = CardSpec.build(:return=>'extension_id', :extension_type=>'User', :_parent=>self).merge(val)
      merge field(:created_by) => ValueSpec.new( [:in, extension_select], self )
    end
    
    def last_edited_by(val)
      extension_select = CardSpec.build(:return=>'extension_id', :extension_type=>'User', :_parent=>self).merge(val)
      merge field(:updated_by) => ValueSpec.new( [:in, extension_select], self ) 
    end

    def merge_extension( ext_type, ext_id_spec)
      merge(
        field(:extension_type)=>ValueSpec.new(ext_type,self), 
        field(:extension_id  )=>ValueSpec.new(['in',ext_id_spec], self)
      )
    end
    
    def creator_of(val)
      merge_extension('User', CardSpec.build(:return=>'created_by', :_parent=>self).merge(val))
    end
    
    def last_editor_of(val)
      merge_extension('User', CardSpec.build(:return=>'updated_by', :_parent=>self).merge(val) )
    end
    
    def editor_of(val)
      inner_spec = CardSpec.build(:_parent=>self).merge(val)
      join_alias = inner_spec.add_join :ed, '(select distinct card_id, created_by from revisions)', :id, :card_id
      inner_spec.merge :return=>"#{join_alias}.created_by"
      merge_extension('User', inner_spec )
    end
    alias :edited :editor_of
    
    def member_of(val)
      inner_spec = CardSpec.build(:extension_type=>'Role', :_parent=>self).merge(val)
      join_alias = inner_spec.add_join :ru, :roles_users, :extension_id, :role_id
      inner_spec.merge :return=>"#{join_alias}.user_id" 
      merge_extension('User',inner_spec )
    end

    def member(val)
      inner_spec = CardSpec.build(:return=>'ru2.role_id', :extension_type=>'User', :_parent=>self).merge(val)
      join_alias = inner_spec.add_join :ru2, :roles_users, :extension_id, :user_id
      inner_spec.merge :return=>"#{join_alias}.role_id"
      merge_extension('Role', inner_spec )
    end
    
    def sort(val)
      return nil if @parent
      val[:return] = val[:return] ? safe_sql(val[:return]) : 'content'
      @mods[:sort] =  "t_sort.#{val[:return]}"
      item = val.delete(:item) || 'left'
      
      if val[:return] == 'count'
        cs_args = { :return=>'count', :group=>'sort_join_field' }
        @mods[:sort] = "coalesce(#{@mods[:sort]},0)"
        case item
        when 'referred_to'
          join_field = 'id'
          cs = CardSpec.build cs_args.merge( field(:cond)=>SqlCond.new("card_id in #{CardSpec.build( val.merge(:return=>'id')).to_sql}") )
          cs.add_join :wr, :wiki_references, :id, :referenced_card_id
        else;  raise "count with item: #{item} not yet implemented"
        end 
      else
        join_field = case item
          when 'left'  ; 'trunk_id'
          when 'right' ; 'tag_id'
          else         ;  raise "sort item: #{item} not yet implemented"
        end 
        cs = CardSpec.build(val)
      end
      
      cs.sql.fields << "#{cs.table_alias}.#{join_field} as sort_join_field"      
      add_join :sort, cs.to_sql, :id, :sort_join_field, :side=>'LEFT'
    end
    
    def subcondition(val, args={})
      args = { :return=>:condition, :_parent=>self }.merge(args)
      cardspec = CardSpec.build( args )
      merge field(:cond) => cardspec.merge(val)
      self.joins.merge! cardspec.joins 
      self.sql.relevance_fields += cardspec.sql.relevance_fields
    end

    def refspec(key, cardspec)
      if cardspec == '_none'
        key = :link_to_missing
        cardspec = 'blank'
      end
      cardspec = CardSpec.build(:return=>'id', :_parent=>self).merge(cardspec)
      merge field(:id) => ValueSpec.new(['in',RefSpec.new([key,cardspec])], self)
    end
    
    def subspec(spec, additions={ :return=>'id'}, negate=false)   
      additions = additions.merge(:_parent=>self)
      operator = negate ? 'not in' : 'in'
      ValueSpec.new([operator,CardSpec.build(additions).merge(spec)], self)
    end 
    
    def to_sql(*args)
      # Basic conditions
      sql.conditions << (@spec.collect do |key, val|
        val.to_sql(key.to_s.gsub(/\:\d+/,''))
      end.join(" #{@mods[:conj].blank? ? :and : @mods[:conj]} "))
      
      return "(" + sql.conditions.last + ")" if @mods[:return]=='condition'

      # Permissions    
      unless System.always_ok? or (Wql.root_perms_only && !root?)
        sql.conditions << %{ (#{table_alias}.read_rule_id IN (#{::User.as_user.read_rule_ids.join ','})) }
      end
           
      sql.fields.unshift fields_to_sql
      sql.order = sort_to_sql  # has side effects!
      sql.tables = "cards #{table_alias}"
      sql.joins += @joins.values                 
      
      sql.conditions << "#{table_alias}.trash is false"
      sql.limit = (@mods[:limit].to_i <= 0) ? "" : "LIMIT #{@mods[:limit].to_i}"
      sql.group = @mods[:group].blank? ? '': "GROUP BY #{safe_sql(@mods[:group])}"
      sql.offset = @mods[:offset].blank? ? "" : "OFFSET #{@mods[:offset].to_i}"
      
      sql.to_s
    end

    def fields_to_sql
      field = @mods[:return]
      case (field.blank? ? :card : field.to_sym)
      when :card; "#{table_alias}.name"
      when :count; "coalesce(count(*),0) as count"
      when :content
        join_alias = add_revision_join
        "#{join_alias}.content"
      else 
        ATTRIBUTES[field.to_sym]==:basic ? "#{table_alias}.#{field}" : safe_sql(field)          
      end
    end
    
    def sort_to_sql
      return nil if @parent or @mods[:return]=='count'
      order_key ||= @mods[:sort].blank? ? "update" : @mods[:sort]
      dir = @mods[:dir].blank? ? (DEFAULT_ORDER_DIRS[order_key.to_sym]||'asc') : safe_sql(@mods[:dir])

      order_field = case order_key
        when "id";              "#{table_alias}.id"
        when "update";          "#{table_alias}.updated_at"
        when "create";          "#{table_alias}.created_at"
        when /^(name|alpha)$/;  "LOWER( #{table_alias}.key )"
        when 'content'
          join_alias = add_revision_join
          "lower(#{join_alias}.content)"
        when "relevance" 
          if !sql.relevance_fields.empty?
            sql.fields << sql.relevance_fields
            "name_rank desc, content_rank" 
          else 
            "#{table_alias}.updated_at"
          end     
        else 
          safe_sql(order_key) 
        end
      order_field = "CAST(#{order_field} AS #{cast_type(@mods[:sort_as])})" if @mods[:sort_as]
      "ORDER BY #{order_field} #{dir}"
      
    end
  end


    
  class RefSpec < Spec
    def initialize(spec)
      @spec = spec   
      @refspecs = {
        :refer_to       => ['card_id','referenced_card_id',''],
        :link_to        => ['card_id','referenced_card_id',"link_type='#{WikiReference::LINK}' AND"],
        :include        => ['card_id','referenced_card_id',"link_type='#{WikiReference::TRANSCLUSION}' AND"],
        :link_to_missing=> ['card_id','referenced_card_id',"link_type='#{WikiReference::WANTED_LINK}'"],
        :referred_to_by => ['referenced_card_id','card_id',''],
        :linked_to_by   => ['referenced_card_id','card_id',"link_type='#{WikiReference::LINK}' AND"],
        :included_by    => ['referenced_card_id','card_id',"link_type='#{WikiReference::TRANSCLUSION}' AND"]
      }
    end
    
    def to_sql(*args)
      f1, f2, where = @refspecs[@spec[0]]
      and_where = (@spec[0] == :link_to_missing) ? '' : "#{f2} IN #{@spec[1].to_sql}"
      %{(select #{f1} from wiki_references where #{where} #{and_where})}
    end
  end
  
  class ValueSpec < Spec
    def initialize(spec, cardspec)
      @cardspec = cardspec
      
      # bare value shortcut
      @spec = case spec   
        when ValueSpec; spec.instance_variable_get('@spec')  # FIXME whatta fucking hack (what's this for?)
        when Array;     spec
        when String;    ['=', spec]
        when Integer;   ['=', spec]
        else raise("Invalid Condition Spec #{spec.inspect}")
      end
       
      # operator aliases
      @spec[0] = @spec[0].to_s
      if target = OPERATORS[@spec[0]]
        @spec[0] = target 
      end

      # check valid operator
      raise("Invalid Operator #{@spec[0]}") unless OPERATORS.has_key?(@spec[0])

      # handle IN
      if @spec[0]=='in' and !@spec[1].is_a?(CardSpec) and !@spec[1].is_a?(RefSpec)
        @spec = [@spec[0], @spec[1..-1]]
      end
    end
    
    def op() @spec[0] end
    
    def sqlize(v)
      case v
        when CardSpec, RefSpec, SqlCond; v.to_sql
        when Array;    "(" + v.flatten.collect {|x| sqlize(x)}.join(',') + ")"
        else quote(v.to_s)
      end
    end
    
    def to_sql(field)
      op,v = @spec
      v=@cardspec.card.name if v=='_self'
      table = @cardspec.table_alias
      
      field, v = case field
        when "cond";     return "(#{sqlize(v)})"
        when "name";     ["#{table}.key",      [v].flatten.map(&:to_cardname).map(&:to_key)]
        
        when "type";     ["#{table}.typecode", [v].flatten.map{ |val| Cardtype.classname_for( val ) }]
        when "content";   join_alias = @cardspec.add_revision_join
                         ["#{join_alias}.content", v]
        else;            ["#{table}.#{safe_sql(field)}", v]
        end
      
      v = v[0] if Array===v && v.length==1
      if op=='~'
        cxn, v = match_prep(v,@cardspec)
        %{#{field} #{cxn.match(sqlize(v))}}
      else
        "#{field} #{op} #{sqlize(v)}"
      end
    end
  end         
end


class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def cast_types()  native_database_types.merge custom_cast_types  end
  def custom_cast_types() {}                                       end
end

class ActiveRecord::ConnectionAdapters::MysqlAdapter
  def custom_cast_types
    { :string  => { :name=>'char'    },
      :integer => { :name=>'signed'  },
      :text    => { :name=>'char'    },
      :float   => { :name=>'decimal' },
      :binary  => { :name=>'binary'  }  }
  end
end
