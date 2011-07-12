class GenerateReadRules < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    ENV['BOOTSTRAP_LOAD'] = 'true'
    
    puts 'updating read_rule fields'
    failed_read_rules = []
    success_count = 0
    
    offset=0
    while (cards=Card.search(:limit=>500, :offset=>offset, :sort=>'id') and cards.size > 0) do
      cards.each do |card|
        begin
          rule = card.setting_card('*read')
          next if rule.name.trunk_name.tag_name == card.read_rule_class
          card.repair_key if card.key != card.name.to_key
          puts "updating read rule for #{card.name};  rule tag_name = #{rule.name.tag_name}, read_rule_class = #{card.read_rule_class}"
          card.update_read_rule
          success_count+=1
        rescue Exception=>e
          fail "FAILURE creating #{card.name}+*self:\n  #{e.inspect}\n\n"
          failed_read_rules << card.name
        end
      end
      offset += 500
    end
    
    puts "successfully updated read rules for #{success_count} cards"
    puts "FAILED - read rule updates failed on the following cards:\n#{failed_read_rules.inspect}" if !failed_read_rules.empty?

    ENV['BOOTSTRAP_LOAD'] = 'false'
  end

  def self.down
  end
end
