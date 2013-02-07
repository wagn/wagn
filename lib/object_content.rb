
require_dependency 'chunks/chunk'
require_dependency 'chunks/uri'
require_dependency 'chunks/literal'
require_dependency 'chunks/reference'
require_dependency 'chunks/link'
require_dependency 'chunks/include'

class ObjectContent < SimpleDelegator

  ACTIVE_CHUNKS = [ URIChunk, HostURIChunk, EmailURIChunk, Literal::Escape, Chunks::Include, Chunks::Link ]
  SCAN_RE = { ACTIVE_CHUNKS => Chunks::Abstract.scan_re(ACTIVE_CHUNKS) }
  PREFIX_LOOKUP = Chunks::Abstract.prefix_cfg

  def initialize content, card_options
    @card_options = card_options
    @card_options[:card] or raise "No Card in Content!!"
    splt = ObjectContent.split_content(card_options, content)
    #warn "split: #{splt.class}, #{splt.inspect}"
    super splt
  end

  attr_reader :revision, :card_options
  def card() @card_options[:card] end
  def renderer() @card_options[:renderer] end

  # for objet_content, it uses this instead of the apply_to by chunk type
  def self.split_content card_params, content
    positions = []

    if String===content
      pre_start = pos = 0
      #warn "scan re C:#{content[pos..-1]} re: #{SCAN_RE[ACTIVE_CHUNKS]}"
      while match = content.match( SCAN_RE[ACTIVE_CHUNKS], pos)
        m_str = match[0]
        first_char = m_str[0,1]
        grp_start = match.begin(0)
        pre_str = pre_start == grp_start ? nil : content[pre_start..grp_start]
        #warn "scan m:#{m_str}[#{match.begin(0)}..#{match.end(0)}] grp:#{grp_start} pos:#{pos}:#{content[pos..match.end(0)]}"
        pos = match.end(0)

        # either it is indexed by the first character of the match
        if match_cfg = PREFIX_LOOKUP[ first_char ]
          rest_match = content[pos..-1].match( Hash===(h = match_cfg[:rest_re]) ? h[m_str[1,1]] : h )

        else # or it uses the default pattern (URIChunk now)
          #warn "PREFIX_LOOKUP[#{ m_str[-1] == ':' ? m_str[-1] : :default} ]"
          match_cfg = PREFIX_LOOKUP[ m_str[-1] ] || PREFIX_LOOKUP[ :default ]
          m_str = ''
          prepend_str = match_cfg[:prepend_str]||''
          #warn "match(#{prepend_str}<>#{content[grp_start..-1]}), #{match_cfg[:idx_char]}"
          rest_match = ( prepend_str+content[grp_start..-1] ).match( match_cfg[:regexp] )
          pos = grp_start - prepend_str.length if rest_match
        end

        #warn "pre_match #{rest_match}#{rest_match && "[#{rest_match.begin(0)}..#{rest_match.end(0)}]"} #{m_str}, #{pre_start}, #{pos}, #{grp_start}, #{content[grp_start..-1]}"
        chunk_class = match_cfg[:class]
        if rest_match
          pos += rest_match.end(0)
        
          #warn "aa #{rest_match}[#{rest_match.begin(0)}..#{rest_match.end(0)}] rto?#{chunk_class.respond_to?( :avoid_autolinking )}, ps:#{pre_start}, pos:#{pos}, gs:#{grp_start}, aa_str:#{content[grp_start-2..grp_start-1]}"
          if grp_start < 1 or !chunk_class.respond_to?( :avoid_autolinking ) or !chunk_class.avoid_autolinking( content[grp_start-2..grp_start-1] )
            # save between strings and chunks indexed by position (probably should just be ordered pairs)
            m, *groups = rest_match.to_a
            #warn "match pre_st[#{match_cfg[:idx_char]}] -- #{pre_start}, pos:#{pos}, gs:#{grp_start}, newp:#{first_char}, rr:#{content[grp_start..-1]}, mstr:#{m_str}, #{groups.map(&:to_s)*', '} :: m:\n#{m}, match:#{rest_match.inspect}"
            rec = [ pos, ( pre_start == grp_start ? nil : content[pre_start..grp_start-1] ), 
                           chunk_class.new(m_str+m, card_params, [first_char, m_str] + groups) ]
            #warn "matched #{grp_start}::#{pos} > #{rec.inspect}"
            pre_start = pos
            positions << rec
          else warn "aa chunk #{match.end(0)} #{content[match.end(0)..-1]}"
          end
        #else warn "nm #{match.end(0)} #{content[match.end(0)..-1]}"
        end
      end
    end

    if positions.any?
      a = positions.inject([]) do |arr, rec|
          pos, pre, chunk = rec
          #warn "inj[#{rec.inspect}] pos#{pos}, pr:#{pre}, c:#{chunk} a:#{arr.inspect}"
          arr << pre if pre
          arr << chunk
        end
      pend = positions[-1][0]
      #warn "arr content<#{pend} :: #{content.length} == #{content.size.inspect}>"
      a << content[pend..-1] unless pend == content.size
      #warn "arr content A:#{a.inspect}"
      a
    else
      #warn "string content:#{content}, #{content.size}"
      content
    end
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
      when Hash;   each { |k,v| yield v if Chunks::Abstract===v }
      when Array;  each { |e|   yield e if Chunks::Abstract===e }
      when String; # strings are all parsed in self, so no chunks in a String
      else
        Rails.logger.warn "error self is unrecognized type #{self.class} #{self.__getobj__.class}"
    end
  end

  def find_chunks chunk_type
    each_chunk.select { |chunk| chunk.kind_of?(chunk_type) }
  end

  def process_content_object &block
    each_chunk { |chunk| chunk.process_chunk &block }
    self
  end

  #def crange(call) call[0..((i=call.index{|x|x=~/gerry/}).nil? ? 4 : i>50 ? 50 : i+5)] << " N: #{i} " end # limited caller for debugging
end
