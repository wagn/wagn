# -*- encoding : utf-8 -*-
module Card::CleanHtml
  class << self
  ## FIXME: clean_html and diff should both be in athe content class.

  ## Dictionary describing allowable HTML
  ## tags and attributes.
    BASIC_TAGS = {
      'a' => ['href', 'title', 'target' ],
      'img' => ['src', 'alt', 'title'],
      'br' => [],
      'i'  => [],
      'b'  => [],
      'pre'=> [],
      'code' => ['lang'],
      'cite'=> [],
      'caption'=> [],
      'strong'=> [],
      'em'  => [],
      'ins' => [],
      'sup' => [],
      'sub' => [],
      'del' => [],
      'ol' => [],
      'hr' => [],
      'ul' => [],
      'li' => [],
      'p'  => [],
      'div'=> [],
      'h1' => [],
      'h2' => [],
      'h3' => [],
      'h4' => [],
      'h5' => [],
      'h6' => [],
      'blockquote' => ['cite'],
      'span'=>[],
      'table'=>[],
      'tr'=>[],
      'td'=>[],
      'th'=>[],
      'tbody'=>[],
      'thead'=>[],
      'tfoot'=>[]
    }

    if Wagn::Conf[:allow_inline_styles]
      BASIC_TAGS['table'] += %w[ cellpadding align border cellspacing ]
    end

    BASIC_TAGS.each_key {|k|
      BASIC_TAGS[k] << 'class'
      BASIC_TAGS[k] << 'style' if Wagn::Conf[:allow_inline_styles]
    }

      ## Method which cleans the String of HTML tags
      ## and attributes outside of the allowed list.

      # this has been hacked for wagn to allow classes in spans if
      # the class begins with "w-"
    def clean!( string, tags = BASIC_TAGS )
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
  end
end
