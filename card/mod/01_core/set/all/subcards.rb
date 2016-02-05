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

def with_id_when_exists card, &block
  card.director.call_after_store &block
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
    subcard.new? && subcard.unfilled? && remove_subcard(key)
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
    card = card_or_id
    if card.id
      write_attribute attribute, card.id
    else
      add_subcard card
      card.director.prior_store = true
      with_id_when_exists(card) do |id|
        write_attribute attribute, id
      end
    end
  else
    write_attribute attribute, card_or_id
  end
end

def subcard_save!
  self.skip_phases = true
  catch_up_to_stage :store
  store_prior_subcards
  save! validate: false
  @virtual = false
  store_subcards
  self
end


# expects a block that saves and returns a card
def save_only_once card
  return card if saved_card_keys.include?(card.key)
  card = yield
  saved_card_keys << card.key
  card
end

def saved_card_keys
  return @supercard.saved_card_keys if @supercard
  @saved_card_keys ||= ::Set.new
end

def prior_save
  @prior_save ||= []
end

event :store_prior_subcards do
  prior_save.each(&:call)
end

event :store_subcards do
  subcards.each do |subcard|
    save_only_once(subcard) do
      subcard.subcard_save!
    end
  end

  # ensures that a supercard can access subcards of self
  # eg. <user> creates <user+*account> creates <user+*account+*status>
f  # <user> changes <user+*account+*status> in event activate_account
  Card.write_to_soft_cache self
end
