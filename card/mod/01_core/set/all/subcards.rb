def field tag
  Card[cardname.field(tag)]
end

def subcard card_name
  subcards.card card_name
end

def subfield field_name
  subcards.field field_name
end

# phase_method :add_subcard, before: :store do |name_or_card, args=nil|
# TODO: handle differently in different stages
def add_subcard name_or_card, args=nil
  subcards.add name_or_card, args
end

# phase_method :add_subfield, before: :approve do |name_or_card, args=nil|
def add_subfield name_or_card, args=nil
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

def deep_clear_subcards
  subcards.deep_clear
end

def unfilled?
  (content.empty? || content.strip.empty?) &&
    (comment.blank? || comment.strip.blank?) &&
    !subcards.present?
end

event :handle_subcard_errors do
  subcards.each do |subcard|
    subcard.errors.each do |field, err|
      err = "#{field} #{err}" unless [:content, :abort].member? field
      errors.add subcard.relative_name.s, err
    end
  end
end

event :reject_empty_subcards, :prepare_to_validate do
  subcards.each_with_key do |subcard, key|
    if subcard.new? && subcard.unfilled?
      remove_subcard(key)
      director.subdirectors.delete(subcard)
    end
  end
end
