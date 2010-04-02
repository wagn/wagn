require 'test/unit'


module Test; module Unit; module Assertions

  # Assert that a block raises a given Exception type matching 
  # a given message
  # 
  # * +types+ - single exception class or array of classes
  # * +matcher+ - Regular Expression to match the inner_text of XML nodes
  # * +diagnostic+ - optional string to add to failure message
  # * +block+ - Ruby statements that should raise an exception
  #
  # Examples:
  # %transclude AssertXPathSuite#test_assert_raise_message_detects_assertion_failure
  #
  # %transclude AssertXPathSuite#test_assert_raise_message_raises_message
  #
  # See: {assert_raise - Don't Just Say "No"}[http://www.oreillynet.com/onlamp/blog/2007/07/assert_raise_on_ruby_dont_just.html]
  #
  def assert_raise_message(types, expected_message, message = nil, &block)
    args = [types].flatten + [message]
    exception = _assert_raise(*args, &block)
    exception_message = exception.message.dup
    
    if expected_message.kind_of? String
      exception_message.gsub!(/^\s+/, '')  #  if we cosmetically strip leading spaces from both the matcher and matchee,
      expected_message.gsub!(/^\s+/, '')  #  then multi-line assert_flunk messages are easier on the eyes!
      expected_message = Regexp.escape(expected_message)
    end

    assert message do
      exception_message.match(expected_message)
    end
    
    return exception.message
  end

  # TODO rebuild this
  def deny_raise_message(types, matcher, diagnostic = nil, &block) #:nodoc:
    exception = assert_raise_message(types, //, diagnostic, &block)
    
    assert_no_match matcher,
                 exception.message,
                 [ diagnostic, 
                   "exception #{ exception.class.name 
                     } with this message should not raise from block:", 
                   "\t"+reflect_source(&block).split("\n").join("\n\t")
                   ].compact.join("\n")
    
    return exception.message
  end

  def assert_flunk(matcher, message = nil, &block)
    assert_raise_message FlunkError, matcher, message, &block
  end

# TODO reinstall ruby-1.9.0 and pass all cross-tests!!

      def _assert_raise(*args)
#        _wrap_assertion do
          if Module === args.last
            message = ""
          else
            message = args.pop
          end
          exceptions, modules = args, [] # _check_exception_class(args)

          expected = args.size == 1 ? args.first : args
          actual_exception = nil
          full_message = build_message(message, "<?> exception expected but none was thrown.", expected)
          assert_block(full_message) do
            begin
              yield
            rescue Exception => actual_exception
              break
            end
            false
          end
          full_message = build_message(message, "<?> exception expected but was\n?", expected, actual_exception)
          assert_block(full_message) {exceptions.include?(actual_exception.class)}
          actual_exception
  #      end
      end

end; end; end

