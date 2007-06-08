class TildeToPlusTransclusions < ActiveRecord::Migration
  def self.up
    User.current_user = WagBot.instance
    Card.find_by_wql("cards with content ~ '\\{\\{'").each do |card|
      revised_content = card.content.gsub( /\{\{((\~)?[^\}]+)\}\}(\**)/ ) do
        card_name = $~[1].strip
        new_name = card_name.gsub( '~', '+' )
        puts "  change: #{card_name} -> #{new_name}" if new_name != card_name
        "{{#{new_name}}}"
      end
      if revised_content != card.content
        card.revise(revised_content)
        puts "Revised #{card.name}"
      end
    end
  end

  def self.down
  end
end
