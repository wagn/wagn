require 'cgi'
require_dependency 'chunks/chunk'
require_dependency 'chunk_manager'

class WikiContent < String    
   class << self
   ## FIXME:  this is still not quite the right place for clean_html! and process_links!
   ##  but it's better than the general string extension library where it was before.
    
   ## Dictionary describing allowable HTML
   ## tags and attributes.
     BASIC_TAGS = {
       'a' => ['href' ],
       'img' => ['src', 'alt', 'title'],
       'br' => [],
       'i' => nil,
#         'u' => nil,
       'b' => nil,
       'pre' => nil,
#         'kbd' => nil,
       'code' => ['lang'],
       'cite' => nil,
       'strong' => nil,
       'em' => nil,
       'ins' => nil,
       'sup' => nil,
       'sub' => nil,
       'del' => nil,
#         'table' => nil,
#         'tr' => nil,
#         'td' => nil,
#         'th' => nil,
       'ol' => nil,       
       'hr' => nil,
       'ul' => nil,
       'li' => nil,
       'p' => nil,
       'h1' => nil,
       'h2' => nil,
       'h3' => nil,
       'h4' => nil,
       'h5' => nil,
       'h6' => nil,
       'blockquote' => ['cite'],
       'span'=>['style']
      }                                             
  

      ## Method which cleans the String of HTML tags
      ## and attributes outside of the allowed list.
      def clean_html!( string, tags = BASIC_TAGS )
        string.gsub!( /<(\/*)(\w+)([^>]*)>/ ) do
          raw = $~
          tag = raw[2].downcase
          if tags.has_key? tag
            pcs = [tag]
            tags[tag].each do |prop|
              ['"', "'", ''].each do |q|
                q2 = ( q != '' ? q : '\s' )
                if raw[3] =~ /#{prop}\s*=\s*#{q}([^#{q2}]+)#{q}/i
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
        string
      end
    
    
      def process_links!(string, url_root=nil)
        string.gsub!( /<a\s+href="([^\"]*)">(.*?)<\/a>/ ) do
          href, text = $~[1],$~[2]
          href.gsub!(url_root,'') if url_root
          if text == href or href=="/wiki/#{text}"
            href.match( /^http:/ ) ? text : "[[#{text}]]"
          else
            "[#{text}][#{href}]"
          end
        end
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
    init_chunk_manager
    # FIXME: apply transcludes first?
    #Include.apply_to(self)
    ACTIVE_CHUNKS.each{|chunk_type| chunk_type.apply_to(self)}
    @not_rendered = String.new(self)
  end

  def pre_render!
    unless @pre_rendered
      # FIXME: unmask transcluded chunks here??
      #@chunks_by_type[Include].each{|chunk| chunk.unmask }
      @pre_rendered = String.new(self)
    end
    @pre_rendered 
  end

  def render!
    pre_render!
    while (gsub!(MASK_RE[ACTIVE_CHUNKS]) do 
       chunk = @chunks_by_id[$~[1].to_i]
       chunk.nil? ? $~[0] : chunk.unmask_text 
      end)
    end
    self
  end
end


# A simplified version of WikiContent. Useful to avoid recursion problems in 
# WikiContent.new
class WikiContentStub < String
  attr_reader :options
  include ChunkManager
  
  def initialize(content)
    super(content)
    init_chunk_manager
  end

  # Detects the mask strings contained in the text of chunks of type chunk_types
  # and yields the corresponding chunk ids
  # example: content = "chunk123categorychunk <pre>chunk456categorychunk</pre>" 
  # inside_chunks(Literal::Pre) ==> yield 456
  def inside_chunks(chunk_types)
    chunk_types.each{|chunk_type|  chunk_type.apply_to(self) }
    
    chunk_types.each{|chunk_type| 
      @chunks_by_type[chunk_type].each{|hide_chunk|
        scan_chunkid(hide_chunk.text){|id| yield id }
      }
    } 
  end
end

