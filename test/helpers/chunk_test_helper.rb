module ChunkTestHelper
  # This module is to be included in unit tests that involve matching chunks.
  # It provides a easy way to test whether a chunk matches a particular string
  # and any the values of any fields that should be set after a match.
  class ContentStub < String
    attr_reader :renderer

    include ChunkManager
    def initialize(str)
      super
      @renderer = Wagn::Renderer::Html.new(nil)
      init_chunk_manager
    end

    def card
    end

    def render_link(*); end
  end

  # Asserts that test_text doesn't match the chunk_type
  def no_match(chunk_type, test_text)
    if chunk_type.respond_to? :pattern
      assert_no_match(chunk_type.pattern, test_text)
    end
  end

  def match(type, test_text, expected)
    pattern = type.pattern
    assert_match(pattern, test_text)
    pattern =~ test_text   # Previous assertion guarantees match
    chunk = type.new($~)

    # Test if requested parts are correct.
    for method_sym, value in expected do
      assert_respond_to(chunk, method_sym)
      assert_equal(value, chunk.method(method_sym).call, "Checking value of '#{method_sym}'")
    end
  end
end


