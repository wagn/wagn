
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

# update entries in reference table
def update_references rendered_content=nil
  raise 'update references should not be called on new cards' if id.nil?

  Card::Reference.delete_all_from self unless self.new_card?
  Card.connection.execute('update cards set references_expired=NULL ' \
                          "where id=#{id}")
  # this update is necessary (for now), because references are often
  # updated outside of the context of an act.
  self.references_expired = nil
  rendered_content ||= Card::Content.new raw_content, self
  rendered_content.find_chunks(Card::Chunk::Reference).each do |chunk|
    create_reference_to chunk
  end
end

def create_reference_to chunk
  referee_name = chunk.referee_name
  return false unless referee_name # eg no commented nest

  referee_name.piece_names.each do |name|
    next if name.key == key # don't create self reference

    # reference types:
    # L = link
    # I = inclusion
    # P = partial (i.e. the name is part of a compound name that is
    #  referenced by a link or inclusion)

    # The partial type is needed to keep track of references of virtual cards.
    # For example a link [[A+*self]] won't make it to the reference table
    # because A+*self is virtual and doesn't have an id but when A's name is
    # changed we have to find and update that link.
    ref_type = name != referee_name ? PARTIAL_REF_CODE : chunk.reference_code
    Card::Reference.create!(
      referer_id:  id,
      referee_id:  Card.fetch_id(name),
      referee_key: name.key,
      ref_type:    ref_type,
      present:     1
    )
  end
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
  expire_structuree_references
end

event :refresh_references_on_create, before: :refresh_references, on: :create do
  Card::Reference.update_existing_key self
  # FIXME: bogus blank default content is set on structured cards...
end

event :refresh_references_on_delete, after: :store, on: :delete do
  Card::Reference.update_on_delete self
  expire_structuree_references
end
