require 'rkelly/visitors'  #  ERGO  advise AP these requirers are broke!
require 'rkelly/visitable'
require 'rkelly/nodes/node'
require 'rkelly/nodes/binary_node'
require 'rkelly/nodes/postfix_node'
require 'rkelly'
require 'assert2/xhtml'

module Test; module Unit; module Assertions

  class AssertRjs
    def initialize(js, command, scope)
      @js, @command, @scope = js, command, scope
    end

    attr_reader :command, :js, :scope, :failure_message
      #  TODO  rename js to sample

    def match(kode)
      RKelly.parse(js).pointcut(kode).
          matches.each do |updater|
        updater.grep(RKelly::Nodes::ArgumentsNode).each do |thang|
          yield thang
        end
      end
    end

#  TODO  implement assert_no_rjs by upgrading scope to UnScope

    def complain(about)
      "#{ command } #{ about }\n#{ js }"
    end
    
    def flunk(about)
      @failure_message ||= complain(about)
    end
    
    def match_or_flunk(why)  
      @text = @text.to_s
      @matcher = @matcher.to_s if @matcher.kind_of?(Symbol)
      return if Regexp.new(@matcher) =~ @text or @text.index(@matcher)
      @failure_message = scope.build_message(complain(why),
                                  "<?> expected to be =~\n<?>.", @text, @matcher)
    end

#  ERGO  blog about how bottom-up TDD decouples
#  ERGO  assert_no_rjs_ ...without! ... oh the humanity!

    def wrap_expectation whatever;  yield;  end unless defined? wrap_expectation

    def assert_xhtml(why, &block)
        #  scope.assert_xhtml @text, complain(why), &block      
      matcher = BeHtmlWith.new(self, &block)
      matcher.message = complain(why)
      matcher.matches?(@text, &block)
      @failure_message = matcher.failure_message
    end

    def pwn_call *args, &block  #  TODO  use or reject the block
      target, matchers_backup = args[0], args[1..-1]
      
      match "#{target}()" do |thang|
        matchers = matchers_backup.dup
        
        thang.value.each do |arg|
#         p arg
          @matcher = matchers.first # or return @text
          
          if @matcher.kind_of?(Hash) and
             hash = props_to_hash(arg) 
            hash_match(hash, @matcher) or break  #  TODO  rename to match_hash
          else
            @text = eval(arg.value)
            @matcher.to_s == @text or /#{ @matcher }/ =~ @text or break
          end
          
          matchers.shift
        end

        matchers.empty? and 
          matchers_backup.length == thang.value.length and 
          return @text 
      end
      
      matchers = matchers_backup.inspect

      flunk("#{ command } to #{ target } with arguments #{ 
                        matchers } not found in #{ js }")
    end

    def props_to_hash(props)
      case props
        when RKelly::Nodes::ObjectLiteralNode
          hash = {}
          
          props.value.each do |thang|
            hash[thang.name.to_sym] = eval(thang.value.value)
          end

          return hash

        else
          return nil
      end
    end

    def hash_match(sample, reference)
      reference.each do |key, value|
        sample[key] == value or
          value.kind_of?(Regexp) && sample[key] =~ value or 
            return false
      end
      
      return true
    end

    class ALERT < AssertRjs
      def pwn *args, &block
        @command = :call
        pwn_call :alert, *args, &block
      end
    end

    class CALL < AssertRjs
      def pwn *args, &block  #  TODO  use or reject the block
        pwn_call *args, &block
      end
    end

    class REMOVE < AssertRjs
      def pwn *args, &block
        @command = :call
        pwn_call 'Element.remove', *args, &block
      end
    end  #  TODO  get the call call out of the error message

    class TOGGLE < AssertRjs
      def pwn *args, &block
        @command = :call
        pwn_call 'Element.toggle', *args, &block
      end
    end

    class INSERT_HTML < AssertRjs
      def pwn *args, &block
        @command = :call
        location, id, html = args
        pwn_call 'Element.insert', id, { location.to_sym => html }, &block
      end
    end

    class REPLACE_HTML < AssertRjs
      def pwn *args, &block
        target, @matcher = args
        @matcher ||= //
        
        match concept do |thang|
          div_id, html = thang.value
          
          if target and html
            div_id = eval(div_id.value)
            html   = html.value.gsub('\u003C', '<').
                                gsub('\u003E', '>')  #  ERGO  give a crap about encoding! 
            html   = eval(html)

            if div_id == target.to_s
              cornplaint = complain("for ID #{ target } has incorrect payload, in")
              @text = html
              match_or_flunk cornplaint if @matcher
              assert_xhtml cornplaint, &block if block
              return html  #  TODO  match any html not just the first. Because!
            end
          end
        end

        flunk "for ID #{ target } not found in"
      end
      def concept;  'Element.update()';  end
    end
    
    class REPLACE < REPLACE_HTML
      def concept;  'Element.replace()';  end
    end
  end

  def __interpret_rjs(response, command, *args, &block)
    klass = command.to_s.upcase
    klass = eval("AssertRjs::#{klass}") rescue
      flunk("#{command} not implemented!")
    asserter = klass.new(response, command, self)
    sample = asserter.pwn(*args, &block)
    return sample, asserter
  end

  def assert_rjs_(*args, &block)
    if args.first.class == Symbol
      command, *args = *args
      response = @response.body
    else
      response, command, *args = *args
    end
    
    sample, asserter = __interpret_rjs(response, command, *args, &block)
    asserter.failure_message and flunk(asserter.failure_message)
    return sample
  end
    
  def assert_no_rjs_(*args, &block)
    if args.first.class == Symbol
      command, *args = *args
      response = @response.body
    else
      response, command, *args = *args  #  TODO  test me!
    end
    
    sample, asserter = __interpret_rjs(response, command, *args, &block)
    asserter.failure_message and return sample
    flunk("should not find #{sample.inspect} in\n#{asserter.js}") #  TODO  complaint system
  end

#     command == :replace_html or  #  TODO  put me inside the method_missing!
#       flunk("assert_rjs's alpha version only respects :replace_html")
#   TODO  also crack out the args correctly and gripe if they wrong
#  TODO TDD the @matcher can be a string or regexp

end; end; end

module Spec; module Matchers

  class SendJsTo
    def initialize(scope, command, *args, &block)
      @scope, @command, @args, @block = scope, command, args, block
    end
 
    def matches?(response, &block)
      @block = block if block
      sample, asserter = @scope.__interpret_rjs(response, @command, @args, &@block)
      @failure_message = asserter.failure_message or
        @negative_failure_message = "should not find #{sample.inspect} in\n#{asserter.js}" #  TODO  complaint system
      return @negative_failure_message
    end
 
    attr_reader :failure_message, :negative_failure_message
  end

  def __interpret_rjs(response, command, *args, &block)
    klass = command.to_s.upcase
    klass = eval("Test::Unit::Assertions::AssertRjs::#{klass}") rescue
      flunk("#{command} not implemented!")
    asserter = klass.new(response, command, self)
    sample = asserter.pwn(*args, &block)
    return sample, asserter
  end  #  ERGO  further merging!
  
  def send_js_to(*args, &block)
    SendJsTo.new(self, *args, &block)
  end
  
  def generate_js_to(*args, &block)
    send_js_to(*args, &block)
  end
end; end
