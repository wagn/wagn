module Wql2  
  # FIXME: this should not be hardcoded
  ANON_ROLE_ID = 1 unless defined?(ANON_ROLE_ID)
  AUTH_ROLE_ID = 2 unless defined?(AUTH_ROLE_ID)
  
  ATTRIBUTES = {
    :basic=> %w{ name content id },
    :system => %w{ trunk_id tag_id },
    :semi_relational=> %w{ type editor member role },
    :relational => %w{ part left right plus },  
    :referential => %w{ link_to linked_to_by refer_to referred_to_by include included_by },
    :special => %w{ or complete },
    :pass => %w{ cond }
  }.inject({}) {|h,pair| pair[1].each {|v| h[v.to_sym]=pair[0] }; h }
  # put into form: { :content=>:basic, :left=>:relational, etc.. }
             
  OPERATORS = %w{ = =~ < > in ~ }.inject({}) {|h,v| h[v]=nil; h }.merge({
    'eq' => '=',
    'gt' => '>',
    'lt' => '<',
    'match' => '~',
  }.stringify_keys)
  
  MODIFIERS = {
    :sort => nil,
    :dir  => nil,
    :limit => nil,
    :offset => nil,
    :return => nil,
    :join  => :and
  }

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
    
    def walk_spec() walk(@spec, :walk_spec); end
  end
  

  class SqlCond < String
    def to_sql(*args)
      self
    end
  end

  class CardSpec < Spec 
    attr_writer :need_revision
    attr_accessor :relevance   
    attr_reader :params
     
    def initialize(spec) 
      @mods = { :join=> :and }
      @spec = {}  
      @params = {}   
      @card, @parent, @need_revision = nil
      @return = :list
      merge(spec)
    end
    
    def root
      @parent ? @parent.root : self
    end
    
    def card   
      @card || raise(Wagn::WqlError, "_self referenced but no card is available")
    end
    
    def merge(spec)
      # string or number shortcut    
      #warn "Merging #{spec.inspect} into #{self}"
      
      spec = case spec
        when "_self";  { :id => root.card.id }
        when "_left";  { :id => root.card.trunk.id }
        when "_right";  { :id => root.card.tag.id }
    #   when "_none";  { }
        when String;   { :name => spec }
        when Integer;  { :id => spec   }  
        when Hash;     spec
        else raise("Invalid cardspec args #{spec.inspect}")
      end
      
      spec = spec.symbolize_keys

      # non-attribute filters shortcut
      spec.each do |key,val|     
        if key==:_card       
          #warn "Assigning Card"      
          @card = spec.delete(key) 
        elsif key==:_parent  
          @parent = spec.delete(key)
        elsif key==:return
          @return = spec.delete(key)
        elsif key.to_s.match(/^_\w+$/)
          @params[key.to_s]= spec.delete(key)
        elsif OPERATORS.has_key?(key.to_s)
          spec.delete(key)
          spec[:content] = [key,val]
        elsif MODIFIERS.has_key?(key)
          @mods[key] = spec.delete(key)
        end
      end

      # process conditions
      spec.each do |key,val|  
        case ATTRIBUTES[key]
          when :basic, :system; spec[key] = ValueSpec.new(val, self)
          when :relational, :semi_relational, :plus, :special; self.send(key, spec.delete(key))    
          when :referential;  self.refspec(key, spec.delete(key))
          when :pass; #noop
          else raise("Invalid attribute #{key}") unless key.to_s.match(/(type|id)\:\d+/)
        end                      
      end
      
      @spec.merge! spec  
      self
    end  
    
    def complete(val)
      no_plus_card = (val=~/\+/ ? '' : "and tag_id is null")  #FIXME -- this should really be more nuanced -- it breaks down after one plus
      merge :cond => SqlCond.new(" lower(name) LIKE lower(#{ActiveRecord::Base.connection.quote(val+'%')}) #{no_plus_card}")
    end
    
    def field(name)
      @fields||={}; @fields[name]||=0; @fields[name]+=1
      "#{name}:#{@fields[name]}"
    end
      
    def type(val)
      merge field(:type) => subspec(val, { :return=>:codename })
    end
    
    def cond(val); #noop      
    end
    
    def or(val)
      merge :cond => CardSpec.new(val).merge(:join=>:or, :return=>:condition, :_parent=>self)
    end

    def left(val)
      merge field(:trunk_id) => subspec(val)
    end

    def right(val)
      merge field(:tag_id) => subspec(val)
    end
    
    def part(val)
      merge :or => { :tag_id => subspec(val), :trunk_id => subspec(val) }
    end

    def plus(val)
      part_spec, connection_spec = val.is_a?(Array) ? val : [ val, {} ]

      merge( :or => {
        field(:id) => subspec(connection_spec, :return=>'trunk_id', :tag_id=>subspec(part_spec)),
        field(:id) => subspec(connection_spec, :return=>'tag_id', :trunk_id=>subspec(part_spec))
      })
    end
                
    def to_sql(*args)
      field = case @return.to_sym
        when :list; 'cards.*'
        when :count; 'count(*)'
        when :first; 'cards.*'
        when :ids;   'id'            
        when :codename; 
          #FIXME: this is not generic codename-- only works for cardtypes
          @need_extension = 'cardtypes'
          'extension.class_name'
        else @return
      end
       
      # gather all the pieces first so that if any of them trigger additional joins it gets flagged
      permission_join, permission_where = permissions
      standard_where = self.conditions                                                                        
      where = "WHERE " + ["cards.trash='f'", permission_where, standard_where].compact.reject{|x|x.blank?}.join(" AND ")                                
      order = self.order
      joins = [permission_join, revision_join, extension_join].join(" ")
      
      case @return        
        when :condition; "("+standard_where+")"   #FIMXE? hmmm, do these conditions need permissions, trash etc?
        else  
          order =  self.order
          limit =  @mods[:limit]  ? "LIMIT #{@mods[:limit].to_i}"    : ""
          offset = @mods[:offset] ? "OFFSET #{@mods[:offset].to_i}"  : ""                                       
          #FIXME: trash condition not db agnostic
          "(select #{field} from cards #{joins} #{where} #{order} #{limit} #{offset})"
        
      end
    end
    
    def order  
      default_dirs =  {
        "update" => "desc",
        "create" => "asc",
        "alpha" => "asc",
        "plusses" => "desc",
        "relevance" => "desc"
      }
      order = @mods[:sort].to_s;  order ='update' if order.blank?
      raise(Wagn::WqlError, "unknown sort key #{order}") unless default_dirs[order]    
      
      dir = @mods[:dir].to_s 
      dir = default_dirs[order] if dir.blank? #|| raise("No direction for order '#{order}'")
      
      sql = case order
        when "update"; "cards.updated_at"
        when "create"; "cards.created_at"
        when "alpha";  "cards.key"
        when "plusses"; "..."    
        when "relevance";  dir=""; self.relevance || "cards.updated_at desc"
      end
                                                                                                  
      ## Plan for plusses:  get the count with a subspec query something like the following:
      # Wql2::CardSpec.new( :right=>{:type=>'Basic'}, :left=> 'sql:outer_alias.id', :return=>:count ).to_sql
      # will have to implement table aliases to get the right join working 
      
      @return.to_sym == :count ? "" : "ORDER BY #{sql} #{dir}"  
    end
    
    def extension_join
      @need_extension ? " join #{@need_extension} as extension on extension.id=cards.extension_id " : ""
    end
    def revision_join
      @need_revision ? " join revisions on revisions.id=cards.current_revision_id " : ""
    end
    
    def permissions
      if System.always_ok?
        [nil,nil]
      elsif User.current_user.login.to_s=='anon'
        [nil, %{ (reader_type='Role' and reader_id=#{ANON_ROLE_ID}) }]
      else
        cuid = User.current_user.id
        ["left join roles_users ru on ru.user_id=#{cuid} and ru.role_id=reader_id",
          %{ ((reader_type='Role' and reader_id IN (#{ANON_ROLE_ID}, #{AUTH_ROLE_ID}))
              OR (reader_type='User' and reader_id=#{cuid})
              OR (reader_type='Role' and ru.user_id is not null)
             )}
        ]
        #statement.pending_group << "ru.user_id"
      end
    end 
   
    def refspec(key, cardspec)
      if cardspec == '_none'
        key = :link_to_missing
        cardspec = 'blank'
      end
      cardspec = CardSpec.new(:return=>'id', :_parent=>self).merge(cardspec)
      merge field(:id) => ValueSpec.new(['in',RefSpec.new([key,cardspec])], self)
    end
    
    def subspec(spec, additions={ :return=>'id' })   
      additions = additions.merge(:_parent=>self)
      ValueSpec.new(['in',CardSpec.new(additions).merge(spec)], self)
    end
    
    def conditions
      @spec.collect do |key, val|   
        key = key.to_s
        key = key.gsub(/\:\d+/,'')  
        val.to_sql(key)
      end.join(" #{@mods[:join]} ")
    end
  end
    
  class RefSpec < Spec
    def initialize(spec)
      @spec = spec   
      @refspecs = {
        :refer_to => ['card_id','referenced_card_id',''],
        :link_to => ['card_id','referenced_card_id',"link_type='#{WikiReference::LINK}' AND"],
        :link_to_missing => ['card_id', 'referenced_card_id', "link_type='#{WikiReference::WANTED_LINK}'"],
        :include => ['card_id','referenced_card_id',"link_type='#{WikiReference::TRANSCLUSION}' AND"],
        :referred_to_by=> ['referenced_card_id', 'card_id', ''],
        :linked_to_by => ['referenced_card_id','card_id',"link_type='#{WikiReference::LINK}' AND"],
        :included_by  => ['referenced_card_id','card_id',"link_type='#{WikiReference::TRANSCLUSION}' AND"]
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
        when ValueSpec; spec.instance_variable_get('@spec')  # FIXME whatta fucking hack
        when Array;     spec
        when String;    ['=', spec]
        when Integer;   ['=', spec]
  #      when nil;       ['is', 'null']
        else raise("Invalid Condition Spec #{spec.inspect}")
      end
      @spec[0] = @spec[0].to_s
       
      # operator aliases
      if target = OPERATORS[@spec[0]]
        @spec[0] = target
      end

      # check valid operator
      raise("Invalid Operator #{@spec[0]}") unless OPERATORS.has_key?(@spec[0])

      # handle IN
      if @spec[0] == :in and !@spec[1].is_a?(CardSpec) and !@spec[1].is_a?(RefSpec)
        @spec = [@spec[0], @spec[1..-1]]
      end
    end
    
    def op
      @spec[0]
    end
    
    def sqlize(v)
      case v
        when CardSpec, RefSpec; v.to_sql
        when Array;    "(" + v.collect {|x| sqlize(x)}.join("','") + ")"
        else ActiveRecord::Base.connection.quote(v)
      end
    end
    
    def to_sql(field)
      @cxn ||= ActiveRecord::Base.connection
      op,v = @spec
      if (String===v &&  v.match(/^_\w+$/) )
        #puts "FOV: #{field} #{op} #{v} #{@cardspec.root.params.inspect}" 
        v = @cardspec.root.params[v] || raise(Wagn::WqlError, "expecting '#{v}' parameter")
      end

      if op == '~' && System.enable_postgres_fulltext   
        v = v.strip.gsub(/\s+/, '&')
        @cardspec.relevance = %{ rank(indexed_name, to_tsquery(#{sqlize(v)}), 1) desc, rank(indexed_content, to_tsquery(#{sqlize(v)}), 1) desc }
        "indexed_content @@ to_tsquery(#{sqlize(v)})" 
      elsif op == '~'
        # FIXME: OMFG this is ugly
        @cardspec.need_revision=true
        '(' + ['key','name','content'].collect do |f|
          sql = v.split(/\s+/).map do |x|
            x.gsub!( /(\*|\+|\(|\))/ ) { '\\\\' + $~[1] }
            "replace(#{@cxn.quote_column_name(f)}, '#{JOINT}',' ') #{@cxn.match(sqlize("[[:<:]]" + x + "[[:>:]]"))}"
          end.join(" AND ")
        end.join(" OR ") + ')'
      elsif field=="content"
        @cardspec.need_revision=true
        "revisions.content #{op} #{sqlize(v)}"
      elsif field=="cond" 
        "(#{sqlize(v)})"
      else   
        field = "cards.#{field}"
        "#{field} #{op} #{sqlize(v)}"
      end          
    end
  end         
end