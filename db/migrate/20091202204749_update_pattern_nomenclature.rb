class UpdatePatternNomenclature < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    [ ['*type',     '*type subtab'],
      ['Pattern',   'Set'],
      ['Knob',      'Setting'],
      ['*solo',     '*self'],
      ['*is type',  '*type'],
      ['*on right', '*right'],
      ['*type and right','*type plus right'],
      ].each do |oldname, newname|
      c = Card[oldname]
      next unless c    
      next if Card[newname]
      c.name = newname
      c.confirm_rename = true
      c.update_referencers = true
      c.save!
    end
    ct = Cardtype.find_by_class_name('Pattern')
    ct.update_attribute :class_name, 'Set'
    ct = Cardtype.find_by_class_name('Knob')
    ct.update_attribute :class_name, 'Setting'
    Card.update_all "type='Setting'", ["type='Knob'"]
    Card.update_all "type='Set'",     ["type='Pattern'"]
  end

  def self.down
  end
end
