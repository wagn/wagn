class Wql
  include ActiveRecord::QuotingAndMatching
  
  ATTRIBUTES = {

    :basic      =>  %w{ name type type_id content id key updater_id trunk_id tag_id creator_id updater_id codename },
    :custom     =>  %w{ edited_by editor_of edited last_editor_of extension_type
       last_edited_by creator_of created_by member_of member role found_by sort
       part left right plus left_plus right_plus or match complete not and },
    :referential => %w{ link_to linked_to_by refer_to referred_to_by include
       included_by },
    :ignore      => %w{ prepend append view params vars size }

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
    
  def initialize( query )  @card_spec = CardSpec.build( query )  end
  def query()              @card_spec.query                      end
  def sql()                @sql ||= @card_spec.to_sql            end
  
  def run
    rows = ActiveRecord::Base.connection.select_all( sql )
    qr=query[:return]
    case qr = qr.nil? ? 'card' : qr.to_s
    when 'card'
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
    when 'count';    rows.first['count'].to_i
    else;           rows.map { |row| row[qr] }
    end
  end  
  
  
  class Spec 
    attr_accessor :spec
    
    def safe_sql(txt)
      txt = txt.to_s
      txt.match( /[^\w\*\(\)\s\.\,]/ ) ? raise( "WQL contains disallowed characters: #{txt}" ) : txt
    end
    
    def quote(v)  ActiveRecord::Base.connection.quote(v)  end
    
    def match_prep(v,cardspec=self)
      cxn ||= ActiveRecord::Base.connection
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
    attr_accessor :fields, :relevance_fields, :tables, :joins, :conditions, :group, :order, :limit, :offset
    
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
    attr_reader :sql, :query, :rawspec
    attr_accessor :joins
    
    class << self
      def build(query)
        cardspec = self.new(query)
        cardspec.merge(cardspec.rawspec)         
      end
    end 
     
    def initialize(query)
      @mods = MODIFIERS.clone
      @joins = {}   
      @selfname, @parent = '', nil
      @spec = {}
      @sql = SqlStatement.new
      
      @query = query.clone
      @query.merge! @query.delete(:params) if @query[:params]
      @vars = @query.delete(:vars) || {}
      @vars.symbolize_keys!
      @query = clean(@query)
      @rawspec = @query.deep_clone
      
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
      name =~ /\b_/ ? name.to_cardname.to_absolute(root.selfname) : name
    end
    
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
      when Wagn::Cardname         ; clean_val val.s
      when Hash                   ; clean val
      when Array                  ; val.map { |v| clean_val v }
      when Integer, Float, Symbol ; val
      else                        ; raise "unknown WQL value type: #{val.class}"
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
        keyroot = key.to_s.sub( /\:\d+$/, '' ).to_sym
        case ATTRIBUTES[keyroot]
          when :basic; spec[key] = ValueSpec.new(val, self)
          when :custom; self.send(keyroot, spec.delete(key))    
          when :referential;  self.refspec(keyroot, spec.delete(key))
          when :ignore; spec.delete(key)
          else keyroot==:cond ? nil : #internal condition
            raise("Invalid attribute #{key}")
        end                      
      end
      
      @spec.merge! spec
      self
    end
    

    
    def cond(val)                                                                   end #noop
    def and(val)   subcondition(val)                                                end
    def or(val)    subcondition(val, :conj=>:or)                                    end
    def not(val)   merge field(:id) => subspec(val, {:return=>'id'}, negate=true)   end
                                                                                    
    def left(val)  merge field(:trunk_id) => subspec(val)                           end
    def right(val) merge field(:tag_id  ) => subspec(val)                           end
    def part(val)  subcondition({ :left => val, :right => val.clone }, :conj=>:or)  end  

    def left_plus(val)
      part_spec, junc_spec = val.is_a?(Array) ? val : [ val, {} ]
      merge( field(:id) => subspec(junc_spec, :return=>'tag_id', :left =>part_spec))      
    end    
    
    def right_plus(val) 
      part_spec, junc_spec = val.is_a?(Array) ? val : [ val, {} ]
      merge( field(:id) => subspec(junc_spec, :return=>'trunk_id', :right=> part_spec ))
    end                                                                                                
    
    def plus(val)
      subcondition( { :left_plus=>val, :right_plus=>val.deep_clone }, :conj=>:or )
    end

    def extension_type(val) add_join(:usr, :users, :id, :card_id)            end
    # this appears to be hacked so that it will only work with users?  
      
    def created_by(val)     merge field(:creator_id) => subspec(val)         end
    def last_edited_by(val) merge field(:updater_id) => subspec(val)         end
    def creator_of(val) merge field(:id)=>subspec(val,:return=>'creator_id') end
    def editor_of(val)      revision_spec(:creator_id, :card_id, val)        end
    def edited_by(val)      revision_spec(:card_id, :creator_id, val)        end
    def last_editor_of(val)
      merge field(:id) => subspec(val, :return=>'updater_id')
    end

    def member_of(val)
      merge field(:right_plus) => [Card::RolesID, {:refer_to=>val}]
    end
    def member(val)
      merge field(:referred_to_by) => {:left=>val, :right=>Card::RolesID }
    end
    
    def revision_spec(field, linkfield, val)
      card_select = CardSpec.build(:_parent=>self, :return=>'id').merge(val).to_sql
      add_join :ed, "(select distinct #{field} from card_revisions where #{linkfield} in #{card_select})", :id, field      
    end
    
    def found_by(val)
      cards = (String===val ? [Card.fetch_or_new(absolute_name(val))] : Wql.new(val).run)
      cards.each do |c|
        raise %{"found_by" value needs to be valid Search card #{c.inspect}} unless c && [Card::SearchTypeID,Card::SetID].include?(c.type_id)
        found_by_spec = CardSpec.new(c.get_spec).rawspec
        merge(field(:id) => subspec(found_by_spec))
      end
    end
    
    def complete(val)
      no_plus_card = (val=~/\+/ ? '' : "and tag_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
      merge field(:cond) => SqlCond.new(" lower(name) LIKE lower(#{quote(val.to_s+'%')}) #{no_plus_card}")
    end
    
    def match(val)
      cxn, v = match_prep(val)
      return nil if v.empty?
      v.gsub!(/\W+/,' ')
      
      cond = begin
        join_alias = add_revision_join
        # FIXME: OMFG this is ugly
        '(' + 
        ["replace(#{self.table_alias}.name,'+',' ')","#{join_alias}.content"].collect do |f|
          v.split(/\s+/).map{ |x| %{#{f} #{cxn.match(quote("[[:<:]]#{x}[[:>:]]"))}} }.join(" AND ")
        end.join(" OR ") + 
        ')'
      end

      merge field(:cond)=>SqlCond.new(cond)
    end
    
    def add_join(name, table, cardfield, otherfield, opts={})
      join_alias = "#{table_alias}_#{name}"
      @joins[join_alias] = "#{opts[:side]} JOIN #{table} AS #{join_alias} ON #{table_alias}.#{cardfield} = #{join_alias}.#{otherfield}"
      join_alias
    end
    
    def add_revision_join
      add_join(:rev, :card_revisions, :current_revision_id, :id)
    end
    
    def field(name)
      @fields||={}; @fields[name]||=0; @fields[name]+=1
      "#{name}:#{@fields[name]}"
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
          cs.add_join :wr, :card_references, :id, :referenced_card_id
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
    
    def subspec(spec, additions={ :return=>'id'}, negate=false)   
      additions = additions.merge(:_parent=>self)
      operator = negate ? 'not in' : 'in'
      ValueSpec.new([operator,CardSpec.build(additions).merge(spec)], self)
    end
    
    def refspec(key, cardspec)
      if cardspec == '_none'
        key = :link_to_missing
        cardspec = 'blank'
      end
      cardspec = CardSpec.build(:return=>'id', :_parent=>self).merge(cardspec)
      merge field(:id) => ValueSpec.new(['in',RefSpec.new([key,cardspec])], self)
    end
    
    def to_sql(*args)
      # Basic conditions
      sql.conditions << (@spec.collect do |key, val|
        val.to_sql(key.to_s.gsub(/\:\d+/,''))
      end.join(" #{@mods[:conj].blank? ? :and : @mods[:conj]} "))
      
      return "(" + sql.conditions.last + ")" if @mods[:return]=='condition'

      # Permissions    
      unless Session.always_ok? or (Wql.root_perms_only && !root?)
        sql.conditions <<
         "(#{table_alias}.read_rule_id IN (#{(rr=Session.as_card.read_rules).nil? ? 1 : rr*','}))"
      end
      #warn "wql perms? #{Session.always_ok?} #{Session.as_id}, #{Session.as_card.read_rules*','} SqCond: #{sql.conditions.inspect}"
           
      sql.fields.unshift fields_to_sql
      sql.order = sort_to_sql  # has side effects!
      sql.tables = "cards #{table_alias}"
      sql.joins += @joins.values                 
      
      sql.conditions << "#{table_alias}.trash is false"
      sql.group = "GROUP BY #{safe_sql(@mods[:group])}" if !@mods[:group].blank? 
      if @mods[:limit].to_i > 0
        sql.limit  = "LIMIT #{@mods[:limit].to_i}"
        sql.offset = "OFFSET #{@mods[:offset].to_i}" if !@mods[:offset].blank? 
      end
      
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
        :link_to        => ['card_id','referenced_card_id',"link_type='#{Card::Reference::LINK}' AND"],
        :include        => ['card_id','referenced_card_id',"link_type='#{Card::Reference::TRANSCLUSION}' AND"],
        :link_to_missing=> ['card_id','referenced_card_id',"link_type='#{Card::Reference::WANTED_LINK}'"],
        :referred_to_by => ['referenced_card_id','card_id',''],
        :linked_to_by   => ['referenced_card_id','card_id',"link_type='#{Card::Reference::LINK}' AND"],
        :included_by    => ['referenced_card_id','card_id',"link_type='#{Card::Reference::TRANSCLUSION}' AND"]
      }
    end
    
    def to_sql(*args)
      f1, f2, where = @refspecs[@spec[0]]
      and_where = (@spec[0] == :link_to_missing) ? '' : "#{f2} IN #{@spec[1].to_sql}"
      %{(select #{f1} from card_references where #{where} #{and_where})}
    end
  end
  
  
  class ValueSpec < Spec
    def initialize(spec, cardspec)
      @cardspec = cardspec
      
      # bare value shortcut
      @spec = case spec   
        when ValueSpec; spec.instance_variable_get('@spec')  # FIXME what a hack (what's this for?)
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
      #warn "to_sql(#{field}), #{op}, #{v}, #{@cardspec.inspect}"
      v=@cardspec.selfname if v=='_self'
      table = @cardspec.table_alias
      
      #warn "to_sql #{field}, #{v} (#{op})"
      field, v = case field
        when "cond";     return "(#{sqlize(v)})"
        when "name";     ["#{table}.key",      [v].flatten.map(&:to_cardname).map(&:to_key)]
        
        when "type";     ["#{table}.type_id", [v].flatten.map{ |val| Card.fetch_id( val )||0 }]
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

