def field tag
  Card[cardname.field(tag)]
end

def subcard card_name
  subcards.card card_name
end

def subfield field_name
  subcards.field field_name
end

phase_method :add_subcard, before: :approve do |name_or_card, args=nil|
  subcards.add name_or_card, args
end

phase_method :add_subfield, before: :approve do |name_or_card, args=nil|
  subcards.add_field name_or_card, args
end

def remove_subcard name_or_card
  subcards.remove name_or_card
end

def remove_subfield name_or_card
  subcards.remove_field name_or_card
end

def clear_subcards
  subcards.clear
end

def unfilled?
  (content.empty? || content.strip.empty?) &&
    (comment.blank? || comment.strip.blank?) &&
    !subcards.present?
end

event :approve_subcards, after: :approve, on: :save do
  subcards.each do |subcard|
    if !subcard.valid_subcard?
      subcard.errors.each do |field, err|
        err = "#{field} #{err}" unless [:content, :abort].member? field
        errors.add subcard.relative_name.s, err
      end
    end
  end
end

event :reject_empty_subcards, before: :approve_subcards do
  subcards.each_with_key do |subcard, key|
    if subcard.new? && subcard.unfilled?
      remove_subcard key
    end
  end
end

# deprecated; left for compatibility reasons because other events refer to this
# especially wikirate
event :process_subcards, after: :reject_empty_subcards, on: :save do
end

event :store_subcards, after: :store do
  subcards.each do |subcard|
    subcard.save! validate: false if subcard != self # unless @draft
  end

  # ensures that a supercard can access subcards of self
  # eg. <user> creates <user+*account> creates <user+*account+*status>
  # <user> changes <user+*account+*status> in event activate_account
  Card.write_to_local_cache self
end
