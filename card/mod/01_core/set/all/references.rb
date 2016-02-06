
PARTIAL_REF_CODE = 'P'

def name_referers link_name=nil
  link_name = link_name.nil? ? key : link_name.to_name.key
  Card.joins(:references_out).where card_references: { referee_key: link_name }
end

def extended_referers
  # FIXME: .. we really just need a number here.
  (descendants + [self]).map(&:referers).flatten.uniq
end

# replace references in card content
def replace_reference_syntax old_name, new_name
  obj_content = Card::Content.new raw_content, self
  obj_content.find_chunks(Card::Chunk::Reference).select do |chunk|
    next unless (old_ref_name = chunk.referee_name)
    next unless (new_ref_name = old_ref_name.replace_part old_name, new_name)
    chunk.referee_name = chunk.replace_reference old_name, new_name
    Card::Reference.where(referee_key: old_ref_name.key)
      .update_all referee_key: new_ref_name.key
  end

  obj_content.to_s
end

# delete old references from this card's content, create new ones
def update_references_out
  delete_references_out
  create_references_out
end

# interpret references from this card's content and
# insert entries in reference table
def create_references_out
  ref_hash = {}
  content_object = Card::Content.new(raw_content, self)
  content_object.find_chunks(Card::Chunk::Reference).each do |chunk|
    interpret_reference ref_hash, chunk.referee_name, chunk.reference_code
  end
  return if ref_hash.empty?
  Card::Reference.mass_insert reference_values_array(ref_hash)
end

# delete references from this card
def delete_references_out
  fail 'id required to delete references' if id.nil?
  Card::Reference.delete_all referer_id: id
end

# interpretation phase helps to prevent duplicate references
# results in hash like:
# { referee1_key: [referee1_id, referee1_type1, referee1_type2],
#   referee2_key...
# }
def interpret_reference ref_hash, referee_name, ref_type
  return unless referee_name # eg commented nest has no referee_name
  referee_key = (referee_name = referee_name.to_name).key
  return if referee_key == key # don't create self reference

  referee_id = Card.fetch_id(referee_name)
  ref_hash[referee_key] ||= [referee_id]
  ref_hash[referee_key] << ref_type

  interpret_partial_references ref_hash, referee_name unless referee_id
end

# Partial references are needed to track references to virtual cards.
# For example a link to virual card [[A+*self]] won't have a referee_id,
# but when A's name is changed we have to find and update that link.
def interpret_partial_references ref_hash, referee_name
  [referee_name.left, referee_name.right].each do |sidename|
    interpret_reference ref_hash, sidename, PARTIAL_REF_CODE
  end
end

# translate interpreted reference hash into values array,
# removing duplicate and unnecessary ref_types
def reference_values_array ref_hash
  values = []
  ref_hash.each do |referee_key, hash_val|
    referee_id = hash_val.shift || 'null'
    ref_types = hash_val.uniq
    ref_types.delete PARTIAL_REF_CODE if ref_types.size > 1
    # partial references are not necessary if there are explicit references
    ref_types.each do |ref_type|
      values << [id, referee_id, "'#{referee_key}'", "'#{ref_type}'"]
    end
  end
  values
end

def referers
  references_in.map(&:referer_id).map(&Card.method(:fetch)).compact
end

def includers
  references_in.where(ref_type: 'I')
               .map(&:referer_id).map(&Card.method(:fetch)).compact
end

def referees
  references_out.map { |ref| Card.fetch ref.referee_key, new: {} }
end

def includees
  references_out.where(ref_type: 'I')
                .map { |ref| Card.fetch ref.referee_key, new: {} }
end

protected

event :refresh_references, after: :store, on: :save, changed: :content do
  update_references_out
end


#event :refresh_references

event :refresh_references_on_create, before: :refresh_references, on: :create do
  Card::Reference.update_referee_key_with_id key, id
end

event :refresh_references_on_delete, after: :store, on: :delete do
  delete_references_out
  Card::Reference.reset_referee id
end
