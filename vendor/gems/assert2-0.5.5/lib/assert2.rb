require 'test/unit'

#  FIXME  the first failing assertion of a batch should suggest you get with Ruby1.9...
#  TODO  install Coulor (flibberty) 
#  TODO  add :verbose => option to assert{}
#  TODO  pay for Staff Benda Bilili  ALBUM: Tr�s Tr�s Fort (Promo Sampler) !
#  TODO  evaluate parts[3]
#  ERGO  if the block is a block, decorate with do-end
#  ERGO  decorate assert_latest's block at fault time

#~ if RUBY_VERSION > '1.8.6'
  #~ puts "\nWarning: This version of assert{ 2.0 } requires\n" +
       #~ "RubyNode, which only works on Ruby versions < 1.8.7.\n" +
       #~ "Upgrade to Ruby1.9, and try 'gem install assert21'\n\n"
#~ end

  #~ def colorize(whatever)
    #~ # FIXME stop ignoring this and start colorizing v2.1!
  #~ end

if RUBY_VERSION < '1.9.0'
  require 'assert2/rubynode_reflector'
else
  require 'assert2/ripper_reflector'
end

#  CONSIDER  fix if an assertion contains more than one command - reflect it all!

module Test; module Unit; module Assertions

  FlunkError = if defined? Test::Unit::AssertionFailedError
                 Test::Unit::AssertionFailedError
               else
                 MiniTest::Assertion
               end

  def add_diagnostic(whatever = nil, &block)
    @__additional_diagnostics ||= []  #  TODO move that inside the reflector object, and persist it thru a test case event
    
    if whatever == :clear
      @__additional_diagnostics = []
      whatever = nil
    end
    
    @__additional_diagnostics += [whatever, block]  # note .compact will take care of them if they don't exist
  end

  def assert(*args, &block)
  #  This assertion calls a block, and faults if it returns
  #  +false+ or +nil+. The fault diagnostic will reflect the
  #  assertion's complete source - with comments - and will
  #  reevaluate the every variable and expression in the
  #  block.
  #
  #  The first argument can be a diagnostic string:
  #
  #    assert("foo failed"){ foo() }
  #
  #  The fault diagnostic will print that line.
  # 
  #  The next time you think to write any of these assertions...
  #  
  #  - +assert+
  #  - +assert_equal+
  #  - +assert_instance_of+
  #  - +assert_kind_of+
  #  - +assert_operator+
  #  - +assert_match+
  #  - +assert_not_nil+
  #  
  #  use <code>assert{ 2.1 }</code> instead.
  #
  #  If no block is provided, the assertion calls +assert_classic+,
  #  which simulates RubyUnit's standard <code>assert()</code>.
    if block
      assert_ *args, &block
    else
      assert_classic *args
    end
    return true # or die trying ;-)
  end

  module Coulor  #:nodoc:
    #  TODO  shell into term-ansicolor!
    def colorize(we_color)
      @@we_color = we_color
    end
    unless defined? BOLD
      BOLD  = "\e[1m" 
      CLEAR = "\e[0m" 
    end       # ERGO  modularize these; anneal with Win32
    def colour(text, colour_code)
      return colour_code + text + CLEAR  if colorize?
      return text
    end
    def colorize?  #  ERGO  how other libraries set these options transparent??
      we_color = (@@we_color rescue true)  #  ERGO  parens needed?
      return false if ENV['EMACS'] == 't'
      return (we_color == :always or we_color && $stdout.tty?)
    end
    def bold(text)
      return BOLD + text + CLEAR  if colorize?
      return text
    end
    def green(text); colour(text, "\e[32m"); end
    def red(text); colour(text, "\e[31m"); end
    def magenta(text); colour(text, "\e[35m"); end
    def blue(text); colour(text, "\e[34m"); end
    def orange(text); colour(text, "\e[3Bm"); end
  end
  
  class RubyReflector
    attr_accessor :captured_block_vars,
                  :args

    include Coulor
    
    def split_and_read(called)
      if called + ':' =~ /([^:]+):(\d+):/
        file, line = $1, $2.to_i
        return File.readlines(file)[line - 1 .. -1]
      end
      
      return nil
    end
    
    def __evaluate_diagnostics
      @__additional_diagnostics.each_with_index do |d, x|
        @__additional_diagnostics[x] = d.call if d.respond_to? :call
      end
    end  #  CONSIDER  pass the same args as blocks take?

    def __build_message(reflection)
      __evaluate_diagnostics
      return (@__additional_diagnostics.uniq + [reflection]).compact.join("\n")
    end  #  TODO  move this fluff to the ruby_reflector!

    def format_inspection(inspection, spaces)
      spaces = ' ' * spaces
      inspection = inspection.gsub('\n'){ "\\n\" +\n \"" } if inspection =~ /^".*"$/
      inspection = inspection.gsub("\n"){ "\n" + spaces }
      return inspection.lstrip
    end

    def format_assertion_result(assertion_source, inspection)
      spaces = " --> ".length
      inspection = format_inspection(inspection, spaces)
      return assertion_source.rstrip + "\n --> #{inspection.lstrip}\n"
    end

    def format_capture(width, snip, value)
      return "#{ format_snip(width, snip) } --> #{ format_value(width, value) }"
    end

    def format_value(width, value)  #  TODO  width is a de-facto instance variable
      width += 4
      source = value.pretty_inspect.rstrip
      return format_inspection(source, width)
    end

    def measure_capture(kap)
      return kap.split("\n").inject(0){|x, v| v.strip.length > x ? v.strip.length : x } if kap.match("\n")
      kap.length
      # TODO  need the if?
    end

  end
  
  def colorize(to_color)
    RubyReflector.new.colorize(to_color)
  end

  #  TODO  work with raw MiniTest 

  # This is a copy of the classic assert, so your pre-existing
  # +assert+ calls will not change their behavior
  #
  if defined? MiniTest::Assertion 
    def assert_classic(test, msg=nil)
      msg ||= "Failed assertion, no message given."
      self._assertions += 1
      unless test then
        msg = msg.call if Proc === msg
        raise MiniTest::Assertion, msg
      end
      true
    end
    
    def add_assertion
      self._assertions += 1
    end
  else
    def assert_classic(boolean, message=nil)
      #_wrap_assertion do
        assert_block("assert<classic> should not be called with a block.") { !block_given? }
        assert_block(build_message(message, "<?> is not true.", boolean)) { boolean }
      #end
    end
  end

  #  The new <code>assert()</code> calls this to interpret
  #  blocks of assertive statements.
  #
  def assert_(diagnostic = nil, options = {}, &block)
    options[:keep_diagnostics] or add_diagnostic :clear
    
    begin
      if got = block.call(*options[:args])
        add_assertion
        return got
      end
    rescue FlunkError
      raise  #  asserts inside assertions that fail do not decorate the outer assertion
    rescue => got
      add_exception got
    end

    flunk diagnose(diagnostic, got, caller[1], options, block)
  end

  def add_exception(ex)
    ex.backtrace[0..10].each do |line|
      add_diagnostic '  ' + line
    end
  end

  #  This assertion replaces:
  #  
  #  - +assert_nil+
  #  - +assert_no_match+
  #  - +assert_not_equal+
  #
  #  It faults, and prints its block's contents and values,
  #  if its block returns non-+false+ and non-+nil+.
  #  
  def deny(diagnostic = nil, options = {}, &block)
      #  "None shall pass!" --the Black Knight
      
    options[:keep_diagnostics] or add_diagnostic :clear
    
    begin
      got = block.call(*options[:args]) or (add_assertion ; return true)
    rescue FlunkError
      raise
    rescue => got
      add_exception got
    end
  
    flunk diagnose(diagnostic, got, caller[0], options, block)
  end  #  "You're a looney!"  -- King Arthur

  def deny_(diagnostic = nil, options = {}, &block)
      #  "None shall pass!" --the Black Knight
      
    options[:keep_diagnostics] or add_diagnostic :clear
    
    begin
      got = block.call(*options[:args]) or (add_assertion ; return true)
    rescue FlunkError
      raise
    rescue => got
      add_exception got
    end
  
    flunk diagnose(diagnostic, got, caller[0], options, block)
  end  #  "You're a looney!"  -- King Arthur

#  FIXME  document why this deny_ is here, and how to alias it back to deny

  alias denigh deny  #  to line assert{ ... } and 
                     #          denigh{ ... } statements up neatly!

  #~ def __reflect_assertion(called, options, block, got)
    #~ effect = RubyReflector.new(called)
    #~ effect.args = *options[:args]
    #~ return effect.reflect_assertion(block, got)
  #~ end

  #~ def __reflect_assertion(called, options, block, got)
    #~ effect = RubyReflector.new(called)
    #~ effect.args = *options[:args]
    #~ effect.block = block
    #~ return effect.reflect_assertion(block, got)  #  TODO  merge this and its copies into assert2_utilities
  #~ end

  #!doc!
  def diagnose(diagnostic = nil, got = nil, called = caller[0],
                options = {}, block = nil)                    #   TODO  make this directly callable
    rf = RubyReflector.new
    rf.diagnose(diagnostic, got, called, options, block, @__additional_diagnostics)
    #~ options = { :args => [] }.merge(options)
     #~ # CONSIDER only capture the block_vars if there be args?
    #~ @__additional_diagnostics.unshift diagnostic
    #~ return __build_message(__reflect_assertion(called, options, block, got))
  end

if RubyReflector::HAS_RUBYNODE
  #  wrap this common idiom:
  #    foo = assemble()
  #    deny{ foo.bar() }
  #    foo.activate()
  #    assert{ foo.bar() }
  #
  #  that becomes:
  #    foo = assemble()
  #
  #    assert_yin_yang proc{ foo.bar() } do
  #      foo.activate()
  #    end
  #
  def assert_yin_yang(*args, &block)
      # prock(s), diagnostic = nil, &block)
    procks, diagnostic = args.partition{|p| p.respond_to? :call }
    block ||= procks.shift
    source = reflect_source(&block)
    fuss = [diagnostic, "fault before calling:", source].compact.join("\n")
    procks.each do |prock|  deny(fuss, &prock);  end
    block.call
    fuss = [diagnostic, "fault after calling:", source].compact.join("\n")
    procks.each do |prock|  assert(fuss, &prock);  end
  end

  #  the prock assertion must pass on both sides of the called block
  #
  def deny_yin_yang(*args, &block)
      # prock(s), diagnostic = nil, &block)
    procks, diagnostic = args.partition{|p| p.respond_to? :call }
    block ||= procks.shift
    source = reflect_source(&block)
    fuss = [diagnostic, "fault before calling:", source].compact.join("\n")
    procks.each do |prock|  assert(fuss, &prock);  end
    block.call
    fuss = [diagnostic, "fault after calling:", source].compact.join("\n")
    procks.each do |prock|  assert(fuss, &prock);  end
  end

end

end ; end ; end

class File
  def self.write(filename, contents)
    open(filename, 'w'){|f|  f.write(contents)  }
  end
end
