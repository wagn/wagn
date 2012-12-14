
require_dependency 'chunks/chunk'
require_dependency 'chunks/uri'
require_dependency 'chunks/literal'
require_dependency 'chunks/reference'
require_dependency 'chunks/link'
require_dependency 'chunks/include'

class ObjectContent < SimpleDelegator

  ACTIVE_CHUNKS =
    [ Literal::Escape, Chunk::Include, Chunk::Link, URIChunk, LocalURIChunk ]
  SCAN_RE = { ACTIVE_CHUNKS => Chunk::Abstract.unmask_re(ACTIVE_CHUNKS) }

  def initialize content, card_options
    @card_options = card_options
    @card_options[:card] or raise "No Card in Content!!"
    super ObjectContent.split_content(card_options, content)
  end

  attr_reader :revision, :card_options
  def card() @card_options[:card] end
  def renderer() @card_options[:renderer] end

  # for objet_content, it uses this instead of the apply_to by chunk type
  def self.split_content card_params, content
    if String===content and !(arr = content.to_s.scan SCAN_RE[ACTIVE_CHUNKS]).empty?
      remainder = $'
      content = arr.map do |match_arr|
          pre_chunk = match_arr.shift; match = match_arr.shift
          match_index = match_arr.index {|x| !x.nil? }
          chunk_class, range = Chunk::Abstract.re_class(match_index)
          chunk_params = match_arr[range]
          newck = chunk_class.new match, card_params, chunk_params
          if newck.avoid_autolinking?
            "#{pre_chunk}#{match}"
          elsif pre_chunk.to_s.size > 0
            [pre_chunk, newck]
          else
            newck
          end
        end.flatten.compact
      content << remainder if remainder.to_s != ''
    end
    content
  end

  def to_s
    case __getobj__
    when Array;    map(&:to_s)*''
    when String;   __getobj__
    when NilClass; raise "Nil ObjectContent"
    else           __getobj__.to_s
    end
  end

  def inspect
    "<#{__getobj__.class}:#{card}:#{self}>"
  end

  def each_chunk
    return enum_for(:each_chunk) unless block_given?
    case __getobj__
      when Hash;   each { |k,v| yield v if Chunk::Abstract===v }
      when Array;  each { |e|   yield e if Chunk::Abstract===e }
      when String; # strings are all parsed in self, so no chunks in a String
      else
        Rails.logger.warn "error self is unrecognized type #{self.class} #{self.__getobj__.class}"
    end
  end

  def find_chunks chunk_type
    each_chunk.select { |chunk| chunk.kind_of?(chunk_type) }
  end

  def process_content &block
    each_chunk { |chunk| chunk.unmask_text &block }
    self
  end

  #def crange(call) call[0..((i=call.index{|x|x=~/gerry/}).nil? ? 4 : i>50 ? 50 : i+5)] << " N: #{i} " end # limited caller for debugging
end
