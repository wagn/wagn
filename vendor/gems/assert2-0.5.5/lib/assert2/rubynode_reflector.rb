require 'pp'


module Test; module Unit; module Assertions

  # ERGO
  #     :bmethod      => [:cval],
  #     :cfunc        => [:argc, :cfnc],
  #     :cref         => [:next, :clss],
  #     :defs         => [:mid, :defn, :recv],
  #     :dmethod      => [:cval],
  #     :dot2         => [:beg, :end],
  #     :dot3         => [:beg, :end],
  #     :dregx_once   => [:next, :lit, :cflag],
  #     :fbody        => [:orig, :mid, :head],
  #     :flip2        => [:cnt, :beg, :end],
  #     :flip3        => [:cnt, :beg, :end],
  #     :gasgn        => [:vid, :value], # entry not supported
  #     :ifunc        => [:tval, :state, :cfnc],
  #     :lasgn        => [:vid, :cnt, :value],
  #     :last         => [],
  #     :match        => [:lit],
  #     :memo         => {:u1_value=>:u1_value}, # different uses in enum.c, variabe.c and eval.c ...
  #     :method       => [:body, :noex, :cnt], # cnt seems to be always 0 in 1.8.4
  #     :module       => [:cpath, :body],
  #     :next         => [:stts],
  #     :opt_n        => [:body],
  #     :to_ary       => [:head],

  #  This +reflect+s a block of code, by evaluating it, reflecting its
  #  source, and reflecting all its intermediate values
  #
  def reflect(&block)
    result = block.call
    rf = RubyReflector.new
    rf.block = block
    
    begin
      waz = rf.colorize?
      rf.colorize(false)
      return rf.result + rf.arrow_result(result) + "\n" + rf.format_evaluations
    ensure
      rf.colorize(waz)
    end
  end
 
  #  This +reflect+s a block of code, /without/ evaluating it.
  #  The function only compiles the source and reflects it as
  #  a string of disassembled Ruby
  #  
  def reflect_source(&block)
    RubyReflector.new(nil, block, false).result
  end

  #  This compiles a string and +reflect+s its source...
  #  as another string.
  #  
  def reflect_string(string)
    rf = RubyReflector.new # def initialize
    rf.block = proc{}
    rf.reflect_values = false
      # pp string.parse_to_nodes.transform
    got = rf.reflect_nodes(string.parse_to_nodes)
    return got
  end

  class RubyReflector  #  this class turns hamburger back into live cattle
    HAS_RIPPER = false
    
    begin
      require 'rubygems'
      require 'rubynode'
      HAS_RUBYNODE = true
    rescue LoadError
      HAS_RUBYNODE = false
    end

    attr_reader :evaluations,
                :result,
                :transformation
    attr_writer :block,
                :reflect_values

    def initialize(called = nil, yo_block = nil, reflect_values = true)  #  note that a block, from your context, is not optional
        #  FIXME  these args are bogus use or lose
      @reflect_values = reflect_values
      @evaluations    = []
      @result         = ''
      @line           = 0
      self.block      = yo_block
    end

    def block=(yo_block)
      @block = yo_block and @block.respond_to?(:body_node) and
        reflect_nodes(@block.body_node)
    end

    def reflect_nodes(body_node)
      if body_node
        @transformation = body_node.transform(:include_node => true)
        return @result = _send(@transformation)
      end
    rescue
      puts "\nOffending line: #{ @line }"
      raise
    end

    def absorb_block_args(code_fragments)  #  CONSIDER a suckier way of detecting 
      @captured_block_vars = nil      #  the block args is indeed remotely possible...
      if code_fragments.first =~ /\|(.*)\|/ or code_fragments[1].to_s =~ /\|(.*)\|/
        @captured_block_vars = $1
      end
    end

    def detect(expression)
      expr = expression
      $__args = nil
      if @args and @captured_block_vars
        expr = "#{@captured_block_vars} = $__args.kind_of?(Array) && $__args.length == 1 ? $__args.first : $__args\n" + 
                expr
        $__args = @args
      end

      begin
        intermediate = eval(expr, @block.binding)
        @evaluations << [expression, intermediate, nil]
      rescue SyntaxError => e
        if e.message.index('syntax error, unexpected \',\'') and expression !~ /\[ /
          return detect('[ ' + expression + ' ]')
        end  #  faint prayer to infinite recursion diety here! (-;

        @evaluations << [expression, nil, e.message]
      rescue => e
        @evaluations << [expression, nil, e.message]
      end
    end

    def eval_intermediate(expression)
      detect(expression)  if @reflect_values
      return expression
    end

    def short_inspect(intermediate)
      pretty = intermediate.inspect
      #  ERGO  Proc is prob'ly rare here!
      pretty = { '#<Proc' => '<Proc>' }.fetch(pretty.split(':').first, pretty)
      prettier = pretty[0..90]
      prettier << '*** '  unless prettier == pretty
      return prettier
    end
    private :short_inspect

    #  ERGO  spew the backrefs (?) any regular expression matchers may emit!
    #  ERGO  don't eval the caller of a block without its block!
    
    def format_evaluations
      max_line = @evaluations.map{|exp, val, prob| exp.length}.sort.last
      already = {}
      lines  = []

      @evaluations.each do |exp, val, prob|
        line = "    #{ exp.center(max_line) } "

        line << if prob then
          orange('--? ' + prob)
        else
          green('--> ') + bold(short_inspect(val))
        end

        lines << line  unless already[line] == true
        already[line] = true
      end
      
      return lines.compact.join("\n")
    end

    def _send(node, thence = '')
      return '' unless node
      return node.to_s + thence  if node.class == Symbol
      target = :"_#{ node.first }"
      last = node.last
      (@line = last[:node].line) rescue nil
      exp    = send(target, last)
      exp << thence  if exp.length > 0
      return exp
    end

    %w( args beg body cond cpath defn else end ensr 
        first head iter ivar lit mid next second
        stts recv resq rest value var vid ).each do |sender|
      define_method sender + '_' do |node, *args|
        return _send(node[sender.to_sym], *args)
      end
    end
    
    ########################################################
    ####  structures

    def _block(node)
      return node.map{|n| _send(n, "\n") }.join
    end

    def _module(node, what = 'module')
      return what + ' ' + cpath_(node) + "\n" + 
               body_(node) + 
           "\nend\n"
    end

    def _method(node)
p node
      return ''
    end

    def _class(node); _module(node, 'class');  end
    def _self(node); 'self'; end
    def _defn(node); _defs(node); end
    def _super(node); 'super(' + args_(node) + ')'; end
    def _zsuper(node); 'super'; end
    def _begin(node); "begin\n" + body_(node) + "\nend\n"; end
    def _ensure(node); head_(node) + "\nensure\n" + ensr_(node); end

    def _sclass(node)
      return 'class << ' + recv_(node) + 
                head_body(node) + 
             "end\n"
    end

    class ScopeMethod #:nodoc:
        #  this is complex because Ruby gloms several different
        #  kinds of variables into one "scope" token, and they
        #  don't directly match their layout in the source code
        
      def _scopic(ref, node)
        @ref        = ref
        @node       = node
        @expression = ''
        @previously = false
        @block_arg  = false
        @splat_arg  = false
        @previous_splat = false
        
        if @node[:tbl]
          @expression << '('
          render_argument_list
          @expression << ')'
        end
        
        @expression << "\n"
        @expression << @ref.next_(@node)
        return @expression
      end
      
      def ulterior_comma(token)
        @expression << ', ' if @index > 0
        @expression << token
        @index = 0
      end
      
      def possible_comma(token)
        @expression << ', ' if @index > 0
        @expression << @ref._send(token)
      end

      def render_argument_list
        @nekst = @node[:next]
        @block = @nekst.last       if @nekst && @nekst.first == :block
        @args  = @block.first.last if @block && @block.first.first == :args
        @rest  = @args[:rest]      if @args
        @opt   = @args[:opt]       if @args

        @node[:tbl].each_with_index do |_n, _index|
          @n, @index = _n, _index
          render_argument
          break if @block_arg
        end
      end
      
      def render_argument
        @splat_arg = @block_arg = false

        if @rest and @rest.first == :lasgn and 
            (@n == nil or @rest.last[:vid] == @n)
          ulterior_comma('*')
          @splat_arg = true
        end

        if @block and (ba = @block[1]) and
            ba.first == :block_arg and ba.last[:vid] == @n
          ulterior_comma('&')
          @block_arg = true
        end

        #  ERGO  Ruby 1.9 changes these rules!!

        if !@previous_splat or @block_arg
          if @opt and @opt.first == :block and #  ERGO  why a @block??
            (lasgn = @opt.last.first).first == :lasgn and
              lasgn.last[:vid] == @n
            @previously = true
            possible_comma(@opt.last.first)
          else
            possible_comma(@n)
            @expression << ' = nil' if @previously and !@block_arg and !@splat_arg
          end

          @previous_splat ||= @splat_arg
        end
      end
    end
    
    def _scope(node)
      return ScopeMethod.new._scopic(self, node)
    end

    def _defs(node)
      return 'def ' + recv_(node, '.') + mid_(node) + 
               defn_(node) + 
             "end\n"
    end

    def _rescue(node)
      if node[:else] == false and node[:head] and 
            node[:resq] and node[:head].first == :vcall
        return head_(node) + ' rescue ' + resq_(node)
      else
        exp = head_(node) + 
                else_(node) +
              "rescue" 
        if node[:resq] and node[:resq].first == :resbody
          body = node[:resq].last  
          exp << ' ' + args_(body)  if body and body[:args]
        end
        return exp + "\n" + resq_(node)
      end
    end

    def _resbody(node)
      return body_(node)
        # already emitted: head_(node) + ' ' + args_(node)
    end

    def _yield(node)
      exp = 'yield'
      exp << '(' + head_(node) + ')'  if node[:head]
      return exp
    end
    
    def _alias(node)
      return "alias #{ lit_(node[:new].last) } #{ lit_(node[:old].last) }"
    end
    
    def _valias(node)
      return "alias #{ node[:new] } #{ node[:old] }"
    end
    
    ########################################################
    ####  control flow
    
    def _if(node)
      expression = '( if ' + eval_parenz{cond_(node)} + ' then '
      expression <<     eval_parenz{body_(node)}  if node[:body]
      expression << ' else ' + 
                        eval_parenz{else_(node)}  if node[:else]
      expression << ' end )'
      return expression
    end

    def _while(node, concept = 'while')
      return '( ' + concept + ' ' + cond_(node) + 
                  head_body(node) + 
             "\nend )"
    end

    def _for(node)
      return '( for ' + var_(node) + ' in ' + iter_(node) + "\n" +
                  body_(node) + "\n" +
               'end )'
    end

    def _args(node); return ''; end  #  _call and _fcall insert the real args
    def _until(node); _while(node, 'until'); end
    def _break(node); 'break'; end
    def _next(node); 'next' ; end
    def _case(node); '( case ' + head_body(node) + "\nend )"; end
    def _when(node); 'when ' + head_body(node) + "\n" + next_(node); end
    def _retry(node); 'retry'; end
    def _redo(node); 'redo'; end
    def head_body(node); head_(node) + "\n" + body_(node); end

    def _return(node)
      exp = 'return'
      return exp unless stts = node[:stts]        
      exp << ' '
      
      if stts.first == :array
        exp << '[' + stts_(node) + ']'
      elsif stts.first == :svalue
        exp << stts_(node)
      else
        exp << eval_parenz{stts_(node)}
      end
      
      return exp
    end
        
    def _postexe(node)
      raise '_postexe called with unexpected arguments' unless node == {} or node.keys == [:node]
      return 'END'
    end

    #       :argscat      => [:body, :head],

    ########################################################
    ####  assignments
    
    def _dasgn_curr(node)
      expression = vid_(node)
      return expression unless value = node[:value]
      expression << ' = '
      we_b_array = value.first == :array
      expression << nest_if(we_b_array, '[', ']'){ value_(node) }
      return expression
    end
    
    def _cdecl(node)
      return _send(node[ node[:vid] == 0 ? :else : :vid ]) + ' = ' + value_(node)
    end
    
    def _dasgn(node); _dasgn_curr(node); end
    def _iasgn(node); _dasgn_curr(node); end
    def _gasgn(node); _dasgn_curr(node); end
    def _lasgn(node); _dasgn_curr(node); end
    def _cvasgn(node); _dasgn_curr(node); end
    
    def _op_asgn2(node)
      expression = ''
      
      if node[:recv].first == :self
        expression << 'self'
      else
        expression << recv_(node)
      end
      
      expression << '.'
      expression << vid_(node[:next].last) + ' ||= ' + value_(node)
      return expression
    end

    ########################################################
    ####  operators
    
    def _and(node, und = 'and')
      return eval_intermediate( '( ' +
               eval_parenz{ first_(node)} + ' ' + und + ' ' +
               eval_parenz{second_(node)} + ' )' )
    end
    
    def _back_ref(node); '$' + node[:nth].chr; end
    def _colon2(node); head_(node, '::') + mid_(node); end
    def _colon3(node); '::' + mid_(node); end
    def _cvar(node); _lvar(node); end
    def _cvdecl(node); vid_(node) + ' = ' + value_(node); end
    def _defined(node); 'defined? ' + head_(node); end
    def _dot2(node); '( ' + beg_(node) + ' .. '  + end_(node) + ' )'; end
    def _dot3(node); '( ' + beg_(node) + ' ... ' + end_(node) + ' )'; end
    def _dregx(node); _dstr(node, '/'); end
    def _dregx_once(node); _dstr(node, '/'); end
    def _dsym(node); ':' + _lit(node[:lit]) + ' ' + rest_(node); end
    def _dvar(node); eval_intermediate(vid_(node)); end
    def _dxstr(node); _dstr(node, '`'); end
    def  eval_parenz; eval_intermediate('( ' + yield + ' )'); end
    def _evstr(node); body_(node); end
    def _false(nada); 'false'; end
    def _gvar(node); vid_(node); end
    def _ivar(node); _dvar(node); end
    def _lit(node); node[:lit].inspect; end
    def _lvar(node); eval_intermediate(vid_(node)); end
    def _match(node); node[:lit].inspect; end
    def  neg_one(node); node == -1 ? '' : _send(node); end
    def _nil(nada); 'nil'  ; end
    def _not(node); '(not(' + body_(node) + '))'; end
    def _nth_ref(node); "$#{ node[:nth] }"; end #  ERGO  eval it?
    def _op_asgn_and(node); _op_asgn_or(node, ' &&= '); end
    def _or(node); _and(node, 'or'); end
    def _str(node); _lit(node); end
    def _svalue(node); head_(node); end
    def _to_ary(node); head_(node); end
    def _true(nada); 'true' ; end
    def _undef(node); 'undef ' + mid_(node); end
    def _vcall(node); mid_(node); end
    def  we_b(node); node.first.first; end
    def _xstr(node); '`' + scrape_literal(node) + '`'; end
    def _zarray(node); return '[]'; end
    
    def _flip2(node)  #  ERGO  what the heck is this??
      p node
      p node.keys
      return ''
    end
        
    def _masgn(node)

      #{:value=>
      #  [:splat,
      #   {:head=>
      #     [:fcall,
      #      {:mid=>:calc_stack,
      #       :args=>
      #        [:array,
      #         [[:vcall, {:mid=>:insn}],
      #          [:vcall, {:mid=>:from}],
      #          [:vcall, {:mid=>:after}],
      #          [:vcall, {:mid=>:opops}]]]}]}],
      # :args=>false,
      # :head=>
      #  [:array,
      #   [[:dasgn_curr, {:value=>false, :vid=>:name}],
      #    [:dasgn_curr, {:value=>false, :vid=>:pops}],
      #    [:dasgn_curr, {:value=>false, :vid=>:rets}],
      #    [:dasgn_curr, {:value=>false, :vid=>:pushs1}],
      #    [:dasgn_curr, {:value=>false, :vid=>:pushs2}]]]}
  
      value, head, args = node.values_at(:value, :head, :args)
      
      if value 
        return '( ' + head_(node) + ' = *' + head_(value.last) + ' )'  if value.first == :splat
        
        if head and args
          exp = head_(node)
          return exp + ', * = ' + value_(node)  if args == -1 
          return exp + ', *' + args_(node) + ' = ' + value_(node)
        end
        
        return '( ' + head_(node) + ' = ' + value_(node) + ' )'  if args == false
      end
      
      if value == false and head == false and args
        return '*' + neg_one(args)
      end

      if head.kind_of?(Array) and head.first == :array
        return head.last.map{|n|
          nest_if(n.first == :masgn, '(', ')'){ _send(n) }
        }.join(', ')
      end

      if head == false and args and value
        return '*' + args_(node) + ' = ' + value_(node)
      end

      return head_(node)
    end

    def _splat(node)
      if (head = node[:head]) and 
          ((we_b_array = head.first == :array) or head.first == :lvar)
        return '*' + nest_if(we_b_array, '[', ']'){ head_(node) }
      end

      return '*' + head_(node)
    end  #  ERGO  raise if any other key!
    
    def _const(node)
      expression = vid_(node)
      q = eval(expression, @block.binding)
      eval_intermediate(expression)  unless q.kind_of?(Module)
      return expression
    rescue  #  ERGO  will someone need to see whatever this was?
      return expression
    end

    def scrape_literal(node, regex = false)
      lit = node[:lit].inspect.gsub(/^"/, '').gsub(/"$/, '')
      lit.gsub!('\\\\', '\\')  if regex
      return lit
    end

    def _dstr(node, delim = '"')
      regex = delim == '/'
      expression = delim + scrape_literal(node, regex)

      if node[:next] and node[:next].first == :array
        (node[:next].last || []).each do |n|
          expression << if n.first == :str
            scrape_literal(n.last, regex)
          else
            '#{ ' + _send(n) + ' }'
          end
        end
      end

      return eval_intermediate(expression + delim)
    end

    def _retry(node)
      raise '_retry called with unexpected arguments' unless node == {} or node.keys == [:node]
      return 'retry'
    end

    def recv_zero_self(node, plus = '')
      recv = node[:recv]
      return 'self' + plus  if recv == 0
      return recv_(node, plus)
    end

    def _attrasgn(node)
      recv, args = node.values_at(:recv, :args)

      if args
        if args.first == :array
          if node[:mid].class == Symbol
            if node[:mid] == :'[]='
              return recv_zero_self(node) + '[' + 
                    _send(args.last.first) + '] = ' + 
                    _send(args.last.last)
            end
            return recv_zero_self(node, '.') + mid_(node) + '(' + _send(args.last.last) + ')'
          end
        end
        
        return recv_zero_self(node) +
                '[' + head_(args.last) + '] = ' + 
                 body_(args.last)
      end

      return recv_zero_self(node, '.') + node[:mid].to_s.gsub(/=$/, '')
    end
    
    def _op_asgn_or(node, op = ' ||= ')
      #  CONSIDER what be :aid?
      #{:value=>[:lasgn, {:value=>[:str, {:lit=>"vm_opts.h"}], :cnt=>2, :vid=>:file}],
      # :aid=>0,
      # :head=>[:lvar, {:cnt=>2, :vid=>:file}]}
      return head_(node) + op + value_(node[:value].last)
    end
       
    def fcall_args(node = nil, methodic = false)
      expression = ''
      return expression  unless node
      expression << ' '  unless methodic
      return expression + nest_if(methodic, '(', ')'){  _send(node)  }
    end    
    
    def _fcall(node)
      exp = mid_(node) + fcall_args(node[:args], true)
      eval_intermediate(exp) unless %w(lambda proc).include?(exp)
      return exp
    end

    def _block_pass(node)
      fcall = node[:iter].last
      return eval_intermediate(recv_(fcall, '.') +
                mid_(fcall) + '(' + args_(fcall, ', ') +
                '&' + body_(node) + ')' )
    end

    def _iter(node)
      var = node[:var]

      return eval_intermediate(
        iter_(node) +
          '{' +
          nest_if(var != false, '|', '|'){ var_(node)  unless var == 0 } +
          nest_if(node[:body] , ' ', ' '){ body_(node) } +
          '}')
    end

    def _array(node)
      nest_if we_b(node) == :array, '[', ']' do
        node.map{ |z|
          exp = _send(z)
          exp << ', '  unless z.object_id == node.last.object_id
          exp
        }.join
      end
    end

    def _hash(node)
      return '{}'  unless node[:head] and (array = node[:head].last)
      expression = '{ '
      
      array.in_groups_of 2 do |key, value|
        expression << _send(key) + ' => ' + _send(value)
        expression << ', '  if value != array.last
      end
      
      return expression + ' }'
    end
    
    def _match2(node)
      #  ERGO  should this work like match3?
      return recv_(node) + ' =~ ' + value_(node)
    end
    
    def we_b_op(node)
      return node[:mid] && node[:mid].to_s !~ /^[a-z]/i
    end
    
    def _match3(node)
      #  ERGO  do :lit and :value exclude each other?
      return recv_(node) + ' =~ ' + _send(node[:lit] || node[:value])
    end
    
    def _block_arg(node)  #  is this ever called?
      return ''  #  note that _scope should not take care of this
    end
    
    class CallMethod
      def bracket_args
        return false unless @mid == '[]'
        @expression << '[' + @ref.args_(@node) + ']'
        return true
      end

      def insert_method_call
        @expression << '.'
        @expression << @mid
        @expression << '(' + @ref.args_(@node) + ')'
        @ref.eval_intermediate(@expression) if @methodic
      end
      
      def operator_and_arguments
        @mid = @ref.mid_(@node)

        unless bracket_args
          @methodic = @mid =~ /[a-z]/i

          if @methodic
            insert_method_call
          else
            @expression << ' '
            @expression << @mid
            @expression << ' '
            nest_args
          end
        end
      end
      
      def nest_args
        return unless @args = @node[:args]
        
        nest_me = @args.first == :array && 
                  @args.last.length == 1 &&
                  (call = @args.last.first).first == :call &&
                  @ref.we_b_op(call.last)

        exp = @ref.nest_if(nest_me, '( ', ' )'){ @ref.args_(@node) }
        @ref.eval_intermediate(exp) if nest_me
        @expression << exp
      end

      def caller(ref, node)
        @ref, @node = ref, node
        @expression = ''
        @recv    = @node[:recv]

        if @recv.first == :block_pass
          @expression << @ref.recv_(@node)
          operator_and_arguments
        else
          nest_me = @recv.first == :call && @ref.we_b_op(@recv.last)

          exp = if @recv.first == :array
            @ref.nest_if(true, '[ ', ' ]'){ @ref.recv_(node) }
          else
            exp2 = @ref.nest_if(nest_me, '( ', ' )'){ @ref.recv_(node) }
            @ref.eval_intermediate(exp2)  if nest_me
            exp2
          end

          @expression << exp
          operator_and_arguments
        end
        return @expression
      end
    end

    def _call(node);  CallMethod.new.caller(self, node);  end

    def nest_if(condition, before, after, &block)
      exp = ''
      exp << before  if condition
      exp << (block.call || '')
      exp << after   if condition
      return exp
    end

    def _op_asgn1(node)  #  ERGO  just look up the list of these?
      return '' unless args = node[:args]
      exp = recv_(node)
      
      if [:'-', :'+', :'*', :'**', :'/', :^, :|, :&, 
          :'<<', :'>>', 
            ].include?(node[:mid]) and 
          node[:recv] and args.first == :argscat

        return exp + 
          "[#{ body_(args.last) }] #{ node[:mid] }= " + head_(args.last)
      end
      
      raise "unexpected mid value #{ node[:mid].inspect } in opcode for X= " unless node[:mid] == 0
            
      if args.first == :argscat and args.last[:body]
        exp << '[' + body_(args.last) + ']'
        exp << ' ||= ' + head_(args.last)
      else
        raise "unexpected arguments in opcode for ||= "
      end
      
      return exp
    end
    
    def _argscat(node)
      return head_(node) + ', *' + 
               nest_if(node[:body].first == :array, '[', ']'){ body_(node) }
    end

    def diagnose(diagnostic, result, called, options, block, additional_diagnostics)
      @__additional_diagnostics = additional_diagnostics
      @__additional_diagnostics.unshift diagnostic
      self.args = options.fetch(:args, [])
      rf = self
      polarity = 'assert{ '
      lines = rf.split_and_read(called) 

      if lines.first =~ /^\s*(assert|deny)/
        polarity = $1 + '{ '
      end
      
      rf.absorb_block_args lines 
      rf.block = block
      effect = " - should #{ 'not ' if polarity =~ /deny/ }pass\n"

      report = rf.magenta(polarity) + rf.bold(rf.result) + rf.magenta(" }") + 
                rf.red(arrow_result(result) + effect) + 
                rf.format_evaluations

      return __build_message(report)
    end
    
    def arrow_result(result) #:nodoc:
      return "\t--> #{ result.inspect }"
    end

  end

end; end; end

unless [].respond_to? :in_groups_of
  class Array
    def in_groups_of(number, fill_with = nil, &block)
      require 'enumerator'
      collection = dup
      collection << fill_with until collection.size.modulo(number).zero?
      collection.each_slice(number, &block)
    end
  end
end
