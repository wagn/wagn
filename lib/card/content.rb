# -*- encoding : utf-8 -*-

class Card
  class Content < SimpleDelegator
    Card.load_chunks
    
    #not sure whether this is   best place.  Could really happen almost anywhere (even before chunk classes are loaded).
    Chunk.register_list :default, [ :URI, :HostURI, :EmailURI, :EscapedLiteral, :Include, :Link ]
    Chunk.register_list :references,                         [ :EscapedLiteral, :Include, :Link ]
      
    attr_reader :revision, :format

    def initialize content, format_or_card
      @format = if Card===format_or_card
        Format.new format_or_card, :format=>nil
      else
        format_or_card
      end
      
      unless Array === content
        content = parse_content content
      end
      super content
    end

    def card
      format.card
    end

    def to_s
      case __getobj__
      when Array;    map(&:to_s)*''
      when String;   __getobj__
      when NilClass; raise "Nil Card::Content"
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

    def process_content_object &block
      each_chunk { |chunk| chunk.process_chunk &block }
      self
    end
    
    def parse_content content
      positions = []

      if String===content
        pre_start = pos = 0
        while match = content[pos..-1].match( Chunk.get_regexp( card.chunk_list ) )
          m_str = match[0]
          first_char = m_str[0,1]
          grp_start = match.begin(0)+pos
      
          pre_str = pre_start == grp_start ? nil : content[pre_start..grp_start]
          #warn "scan m:#{m_str}[#{first_char}, #{m_str[-1,1]}, #{match.begin(0)}..#{match.end(0)}] grp:#{grp_start} pos:#{pos}:#{content[pos..match.end(0)]}"
          pos += match.end(0)

          # either it is indexed by the first character of the match
          if match_cfg = Chunk.prefix_cfg[ first_char ]
            rest_match = content[pos..-1].match( Hash===(h = match_cfg[:rest_re]) ? h[m_str[1,1]] : h )

          else # or it uses the default pattern (Chunk::URI now)
            match_cfg = Chunk.prefix_cfg[ m_str[-1,1] ] || Chunk.prefix_cfg[ :default ]
            prepend_str = match_cfg[:prepend_str]
            prepend_str = (m_str[-1,1] != ':' && prepend_str) ? prepend_str : ''
            #warn "pp #{match_cfg[:class]}, #{prepend_str.inspect} [#{m_str}, #{prepend_str}]"
            m_str = ''
            rest_match = ( prepend_str+content[grp_start..-1] ).match( match_cfg[:regexp] )
            pos = grp_start - prepend_str.length if rest_match
          end

          chunk_class = match_cfg[:class]
          if rest_match
            pos += rest_match.end(0)
      
            begin
              if grp_start < 1 or !chunk_class.respond_to?( :avoid_autolinking ) or !chunk_class.avoid_autolinking( content[grp_start-2..grp_start-1] )
                # save between strings and chunks indexed by position (probably should just be ordered pairs)
                m, *groups = rest_match.to_a
                rec = [ pos, ( pre_start == grp_start ? nil : content[pre_start..grp_start-1] ), 
                               chunk_class.new(m_str+m, self, [first_char, m_str] + groups) ]
                pre_start = pos
                positions << rec
              end
            rescue URI::Error=>e
              #warn "rescue parse #{chunk_class}: '#{m}' #{e.inspect} #{e.backtrace*"\n"}"
              Rails.logger.warn "rescue parse #{chunk_class}: '#{m}' #{e.inspect}"
            end
          end
        end
      end

      if positions.any?
        result = positions.inject([]) do |arr, rec|
            pos, pre, chunk = rec
            arr << pre if pre
            arr << chunk
          end
        pend = positions[-1][0]
        result << content[pend..-1] unless pend == content.size
        result
      else
        #warn "string content:#{content}, #{content.size}"
        content
      end
    end

    
    
  
    @@allowed_tags = {}
    %w{ 
      br i b pre cite caption strong em ins sup sub del ol hr ul li p 
      div h1 h2 h3 h4 h5 h6 span table tr td th tbody thead tfoot
    }.each { |tag| @@allowed_tags[tag] = [] }
  
    # allowed attributes
    @@allowed_tags.merge!(
      'a' => ['href', 'title', 'target' ],
      'img' => ['src', 'alt', 'title'],
      'code' => ['lang'],
      'blockquote' => ['cite']
    )

    if Wagn::Conf[:allow_inline_styles]
      @@allowed_tags['table'] += %w[ cellpadding align border cellspacing ]
    end

    @@allowed_tags.each_key {|k|
      @@allowed_tags[k] << 'class'
      @@allowed_tags[k] << 'style' if Wagn::Conf[:allow_inline_styles]
    }
  
    class << self

      ## Method that cleans the String of HTML tags
      ## and attributes outside of the allowed list.

      # this has been hacked for wagn to allow classes in spans if
      # the class begins with "w-"
      def clean!( string, tags = @@allowed_tags )
        string.gsub!( /<(\/*)(\w+)([^>]*)>/ ) do
          raw = $~
          tag = raw[2].downcase
          if tags.has_key? tag
            pcs = [tag]
            tags[tag].each do |prop|
              ['"', "'", ''].each do |q|
                q2 = ( q != '' ? q : '\s' )
                if prop=='class'
                  if raw[3] =~ /#{prop}\s*=\s*#{q}(w-[^#{q2}]+)#{q}/i
                    pcs << "#{prop}=\"#{$1.gsub('"', '\\"')}\""
                    break
                  end
                elsif raw[3] =~ /#{prop}\s*=\s*#{q}([^#{q2}]+)#{q}/i
                  pcs << "#{prop}=\"#{$1.gsub('"', '\\"')}\""
                  break
                end
              end
            end if tags[tag]
            "<#{raw[1]}#{pcs.join " "}>"
          else
            " "
          end
        end
        string.gsub!(/<\!--.*?-->/, '')
        string
      end
    
    
      def truncatewords_with_closing_tags(input, words = 25, truncate_string = "...")
        if input.nil? then return end
        wordlist = input.to_s.split
        l = words.to_i - 1
        l = 0 if l < 0
        wordstring = wordlist.length > l ? wordlist[0..l].join(" ") : input.to_s
        # nuke partial tags at end of snippet
        wordstring.gsub!(/(<[^\>]+)$/,'')

        tags = []

        # match tags with or without self closing (ie. <foo />)
        wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\>/).each { |t| tags.unshift(t[0]) }
        # match tags with self closing and mark them as closed
        wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\/\>/).each { |t| if !(x=tags.index(t[0])).nil? then tags.slice!(x) end }
        # match close tags
        wordstring.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t|  if !(x=tags.rindex(t[0])).nil? then tags.slice!(x) end  }

        tags.each {|t| wordstring += "</#{t}>" }

        wordstring +='<span class="closed-content-ellipses">...</span>' if wordlist.length > l
    #    wordstring += '...' if wordlist.length > l
        wordstring.gsub! /<[\/]?br[\s\/]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring.gsub! /<[\/]?p[^>]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring
      end
    
    end
  end
end