class Card
  class Content
    # tools for truncating content
    module Truncate
      def smart_truncate input, words=25
        return if input.nil?
        truncated, wordstring = truncate input, words
        # nuke partial tags at end of snippet
        wordstring.gsub!(/(<[^\>]+)$/, "")
        wordstring = close_tags wordstring
        wordstring += ELLISPES_HTML if truncated
        # wordstring += '...' if wordlist.length > l
        polish wordstring
      end

      def truncate input, words
        wordlist = input.to_s.split
        l = words.to_i - 1
        l = 0 if l < 0
        truncating = wordlist.length > l
        wordstring = truncating ? wordlist[0..l].join(" ") : input.to_s
        [truncating, wordstring]
      end

      def close_tags wordstring
        tags = find_tags wordstring
        tags.each { |t| wordstring += "</#{t}>" }
        wordstring
      end

      def polish wordstring
        wordstring.gsub! %r{<[/]?br[\s/]*>}, " "
        # Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring.gsub! %r{<[/]?p[^>]*>}, " "
        ## Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring
      end

      def find_tags wordstring
        tags = []

        # match tags with or without self closing (ie. <foo />)
        wordstring.scan(%r{\<([^\>\s/]+)[^\>]*?\>}).each do |t|
          tags.unshift(t[0])
        end
        # match tags with self closing and mark them as closed
        wordstring.scan(%r{\<([^\>\s/]+)[^\>]*?/\>}).each do |t|
          next unless (x = tags.index(t[0]))
          tags.slice!(x)
        end
        # match close tags
        wordstring.scan(%r{\</([^\>\s/]+)[^\>]*?\>}).each do |t|
          next unless (x = tags.rindex(t[0]))
          tags.slice!(x)
        end
        tags
      end
    end
  end
end
