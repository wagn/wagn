# -*- encoding : utf-8 -*-

require_dependency 'card/chunk'
# you could make the case that Card::Chunk should be Card::Content::Chunk, which would make the above unnecessary (but create noise elsewhere)

class Card
  class Content < SimpleDelegator      
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
        position = 0
        prefix_regexp = Chunk.get_prefix_regexp card.chunk_list
        interval_string = ''
        
        while prefix_match = content[position..-1].match( prefix_regexp )
          prefix = prefix_match[0]
          chunk_start = prefix_match.begin(0) + position

          if prefix_match.begin(0) > 0
            interval_string += content[ position..chunk_start-1 ]
          end

          chunk_class = Chunk.find_class_by_prefix prefix
          match, offset = chunk_class.full_match content[chunk_start..-1], prefix
          context_ok = chunk_class.context_ok? content, chunk_start
          
          position = chunk_start
          
          if match
            position += ( match.end(0) - offset.to_i )
            if context_ok
              if interval_string.size > 0
                positions << [ interval_string ] 
                interval_string = ''
              end
              positions << [ chunk_class.new(match, self), position ]
            end
          else
            position += 1
          end
          
          interval_string += prefix if !match || !context_ok
        end
      end

      if positions.any?
        result = positions.map { |pos| pos[0] }
        last_tracked_position = positions[-1][1]
        if last_tracked_position < content.size
          remainder = content[ last_tracked_position..-1]
          result << remainder
        end
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
