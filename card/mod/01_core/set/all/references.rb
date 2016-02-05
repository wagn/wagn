
PARTIAL_REF_CODE = 'P'

def name_referencers link_name=nil
  link_name = link_name.nil? ? key : link_name.to_name.key
  Card.joins(:references_to).where card_references: { referee_key: link_name }
end

def extended_referencers
  # FIXME: .. we really just need a number here.
  (descendants + [self]).map(&:referencers).flatten.uniq
end

# replace references in card content
def replace_references old_name, new_name
  obj_content = Card::Content.new raw_content, self
  obj_content.find_chunks(Card::Chunk::Reference).select do |chunk|
    next unless (old_ref_name = chunk.referee_name)
    next unless (new_ref_name = old_ref_name.replace_part old_name, new_name)
    chunk.referee_name = chunk.replace_reference old_name, new_name
    old_references = Card::Reference.where(referee_key: old_ref_name.key)
    old_references.update_all referee_key: new_ref_name.key
  end

  obj_content.to_s
end

# delete current references where applicable,
# interpret references from content and
# insert entries in reference table
def update_references
  fail 'update references should not be called on new cards' if id.nil?

  Card::Reference.delete_all_from self unless new_card?
  ref_hash = {}
  content_object = Card::Content.new(raw_content, self)
  content_object.find_chunks(Card::Chunk::Reference).each do |chunk|
    interpret_reference ref_hash, chunk.referee_name, chunk.reference_code
  end
  create_references_from_hash ref_hash
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

  return if referee_id
  # Partial references are needed to track references to virtual cards.
  # For example a link to virual card [[A+*self]] won't have a referee_id,
  # but when A's name is changed we have to find and update that link.
  [referee_name.left, referee_name.right].each do |sidename|
    interpret_reference ref_hash, sidename, PARTIAL_REF_CODE
  end
end

# translate hash into values array, removing duplicate and unnecessary
# ref_types, and create with values_array
def create_references_from_hash ref_hash
  values = []
  ref_hash.each do |referee_key, hash_val|
    referee_id = hash_val.shift
    ref_types = hash_val.uniq
    if ref_types.size > 1
      # partial references are not necessary if there are explicit references
      ref_types.delete PARTIAL_REF_CODE
    end
    ref_types.each do |ref_type|
      values << [id, referee_id, "'#{referee_key}'", "'#{ref_type}'"]
    end
  end
  create_references_from_array values
end

# array takes form [ [referer_id, referee_id, referee_key, ref_type], ...]
def create_references_from_array array
  return if array.empty?
  value_statements = array.map do |values|
    "\n(#{values.join ', '})"
  end
  sql = 'INSERT into card_references '\
        '(referer_id, referee_id, referee_key, ref_type) '\
        "VALUES #{value_statements.join ', '}"
  Card.connection.execute sql
  # bulk insert improves performance considerably
end

def referencers
  references_from.map(&:referer_id).map(&Card.method(:fetch)).compact
end

def includers
  references_from.where(ref_type: 'I')
                 .map(&:referer_id).map(&Card.method(:fetch)).compact
end

def referees
  references_to.map { |ref| Card.fetch ref.referee_key, new: {} }
end

def includees
  references_to.where(ref_type: 'I')
               .map { |ref| Card.fetch ref.referee_key, new: {} }
end

protected

event :refresh_references, after: :store, on: :save, changed: :content do
  update_references
end

event :refresh_references_on_create, before: :refresh_references, on: :create do
  Card::Reference.update_existing_key self
  # FIXME: bogus blank default content is set on structured cards...
end

event :refresh_references_on_delete, after: :store, on: :delete do
  Card::Reference.update_on_delete self
end
