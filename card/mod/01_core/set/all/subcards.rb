def field tag
  Card[cardname.field(tag)]
end

def subcard card_name
  subcards.card card_name
end

def subfield field_name
  subcards.field field_name
end

#phase_method :add_subcard, :before=>:approve do |name_or_card, args = nil|
def add_subcard name_or_card, args = nil
  subcards.add name_or_card, args
end

def add_subfield name, args = nil
#phase_method :add_subfield, :before=>:approve do |name, args = nil|
  subcards.add_field name, args
end

def remove_subcard name_or_card
  subcards.remove name_or_card
end

def remove_subfield name_or_card
  subcards.remove_field name_or_card
end

event :filter_empty_subcards, after: :approve, on: :save do
  subcards.each_card do |subcard|
    if subcard.new? &&
       (subcard.content.empty? || subcard.content.strip.empty?) &&
       !subcard.subcards.present? &&
       (!subcard.respond_to? :attachment || !subcard.attachment.present?)
      # TODO: check if attachment check is necessary; depends on whether
      # attachment cards write the identifier to db_content before or after
      # this event
      remove_subcard subcard
    end
  end
end

# left for compatibility reasons because other events refer to this
event :process_subcards, after: :filter_empty_subcards, on: :save do
end

event :approve_subcards, after: :process_subcards do
  subcards.each do |subcard|
    if !subcard.valid_subcard?
      subcard.errors.each do |field, err|
        err = "#{field} #{err}" unless [:content, :abort].member? field
        errors.add subcard.relative_name.s, err
      end
    end
  end
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