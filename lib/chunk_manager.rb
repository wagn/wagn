require_dependency 'chunks/chunk'
require_dependency 'chunks/uri'
require_dependency 'chunks/literal'
require_dependency 'chunks/reference'
require_dependency 'chunks/link'
require_dependency 'chunks/transclude'


module ChunkManager
  attr_reader :chunks_by_type, :chunks_by_id, :chunks, :chunk_id
  unless defined? ACTIVE_CHUNKS
    ACTIVE_CHUNKS = [ 
      Literal::Pre,
      Literal::Escape,
      Chunk::Transclude,
      Chunk::Link,
      URIChunk, 
      LocalURIChunk 
    ] 
  
#    HIDE_CHUNKS = [ Literal::Pre, Literal::Tags ]
  
    MASK_RE = { 
#      HIDE_CHUNKS => Chunk::Abstract.mask_re(HIDE_CHUNKS),
      ACTIVE_CHUNKS => Chunk::Abstract.mask_re(ACTIVE_CHUNKS)
    }
  end
  
  def init_chunk_manager
    @chunks_by_type = Hash.new
    Chunk::Abstract.descendents.each{|chunk_type| 
      @chunks_by_type[chunk_type] = Array.new 
    }
    @chunks_by_id = Hash.new
    @chunks = []
    @chunk_id = 0
  end

  def add_chunk(c)
    @chunks_by_type[c.class] << c
    @chunks_by_id[c.object_id] = c
    @chunks << c
    @chunk_id += 1
  end

  def delete_chunk(c)
    @chunks_by_type[c.class].delete(c)
    @chunks_by_id.delete(c.object_id)
    @chunks.delete(c)
  end

  def merge_chunks(other)
    other.chunks.each{|c| add_chunk(c)}
  end

  def scan_chunkid(text)
    text.scan(MASK_RE[ACTIVE_CHUNKS]){|a| yield a[0] }
  end
  
  def find_chunks(chunk_type)
    @chunks.select { |chunk| chunk.kind_of?(chunk_type) and chunk.rendered? }
  end
  

end
