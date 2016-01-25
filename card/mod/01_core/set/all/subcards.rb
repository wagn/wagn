def field tag
  Card[cardname.field(tag)]
end

def subcard card_name
  subcards.card card_name
end

def subfield field_name
  subcards.field field_name
end

#phase_method :add_subcard, before: :store do |name_or_card, args=nil|
# TODO: handle differently in different stages
def add_subcard name_or_card, args=nil
  subcards.add name_or_card, args
end
  #end

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

def right_id= card_or_id
  write_card_or_id :right_id, card_or_id
end
def left_id= card_or_id
  write_card_or_id :left_id, card_or_id
end
def type_id= card_or_id
  write_card_or_id :type_id, card_or_id
end

def write_card_or_id attribute, card_or_id
  if card_or_id.is_a? Card
    if card_or_id.id
      write_attribute attribute, card_or_id.id
    else
      @prior_save << proc do
        save_only_once(card_or_id) do
          card_or_id.save! validate: false
        end
        write_attribute attribute, card.id
      end
    end
  else
    write_attribute attribute, card_or_id
  end
end

def save_only_once card, &block
  return card if saved_card_keys.include?(card.key) || card != self
  card = yield
  saved_card_keys << card.key
  card
end

def saved_card_keys
  return @supercard.saved_card_keys if @supercard
  @saved_card_keys ||= ::Set.new
end

event :store_prior_subcards do
  @prior_save.each do |save_block|
    save_block.call
  end
end

event :store_subcards do
  subcards.each do |subcard|
    save_only_once(subcard) do
      subcard.save! validate: false
    end
  end

  # ensures that a supercard can access subcards of self
  # eg. <user> creates <user+*account> creates <user+*account+*status>
  # <user> changes <user+*account+*status> in event activate_account
  Card.write_to_soft_cache self
end


# event :clean_subcards, after: :clean do
#   subcards.each do |subcard|
#     subcard.run_callbacks :clean
#   end
# end

# event :finish_subcards, after: :finish do
#   subcards.each do |subcard|
#     subcard.run_callbacks :finish
#   end
# end
#
# event :followup_subcards, after: :followup do
#   subcards.each do |subcard|
#     subcard.run_callbacks :followup
#   end
# end
