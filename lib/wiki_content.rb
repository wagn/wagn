require 'cgi'
require_dependency 'chunks/chunk'
require_dependency 'chunk_manager'

class MissingChunk < StandardError; end

class WikiContent < String
  class << self
  ## FIXME:  this is still not quite the right place for clean_html!
  ##  but it's better than the general string extension library where it was before.

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

    BASIC_TAGS.each_key do |k| 
      BASIC_TAGS[k] << 'class'
      BASIC_TAGS[k] << 'style' if Wagn::Conf[:allow_inline_styles]
    end

      ## Method which cleans the String of HTML tags
      ## and attributes outside of the allowed list.

      # this has been hacked for wagn to allow classes in spans if
      # the class begins with "w-" or "ui-"
    def clean_html! string, tags = BASIC_TAGS
      string.gsub!( /<(\/*)(\w+)([^>]*)>/ ) do
        raw = $~
        tag = raw[2].downcase
        if tags.has_key? tag
          pcs = [tag]
          tags[tag].each do |prop|
            ['"', "'", ''].each do |q|
              q2 = ( q != '' ? q : '\s' )
              if prop=='class'
                if raw[3] =~ /#{prop}\s*=\s*#{q}((w|ui)-[^#{q2}]+)#{q}/i
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
      string.gsub! /<\!--.*?-->/m, ''
      string
    end
  end

  include ChunkManager
  attr_reader :revision, :not_rendered, :pre_rendered, :renderer, :card

  def initialize(card, content, renderer)
    @not_rendered = @pre_rendered = nil
    @renderer = renderer
    @card = card or raise "No Card in Content!!"
    super(content)
    init_chunk_manager()
    ACTIVE_CHUNKS.each{|chunk_type| chunk_type.apply_to(self)}
#Rails.logger.debug "wiki content init #{card.name}, C:#{content}" #\nTrace #{Kernel.caller.slice(0,6).join("\n")}"
    @not_rendered = String.new(self)
  end

  def pre_render!
    unless @pre_rendered
      @pre_rendered = String.new(self)
    end
    @pre_rendered
  end

  def render!( revert = false, &block)
    pre_render!
    while (gsub!(MASK_RE[ACTIVE_CHUNKS]) do
       chunk = @chunks_by_id[$~[1].to_i]
       chunk.nil? ? $~[0] : ( revert ? chunk.revert : chunk.unmask_text(&block) )
      end)
    end
#Rails.logger.debug "wiki render! #{@card.name} #{self.slice(0,80)}\nTrace #{Kernel.caller.slice(0,5).join("\n")}" unless revert
    self
  end

  def unrender!
    render!( revert = true )
  end

end


