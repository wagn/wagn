def to_s
  "#<#{self.class.name}[#{debug_type}]#{attributes['name']}>"
end

def inspect
  tags = []
  tags << "trash"    if trash
  tags << "new"      if new_card?
  tags << "frozen"   if frozen?
  tags << "readonly" if readonly?
  tags << "virtual"  if @virtual
  tags << "set_mods_loaded" if @set_mods_loaded

  error_messages = errors.any? ? "<E*#{errors.full_messages * ', '}*>" : ""

  "#<Card##{id}[#{debug_type}](#{name})#{error_messages}{#{tags * ','}}"
end

private

def debug_type
  "#{type_code || ''}:#{type_id}"
end
