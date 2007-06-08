task :convert_markdown => :environment do
  require_gem 'BlueCloth'
  User.current_user = HoozeBot.new.user
  Card.find(:all, :order=>'name').each do |card|
    puts "Converting #{card.name}"
    html = BlueCloth.new(card.content || "").to_html
    if html!=card.content
      card.content = html
    end
  end
end

