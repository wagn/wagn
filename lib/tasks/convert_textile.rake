task :convert_textile => :environment do
  require_gem 'RedCloth'
  User.current_user = WagBot.instance
  Card.find(:all, :order=>'name').each do |card|
    puts "Converting #{card.name}"
    r = RedCloth.new(card.content || "")
    html = r.to_html
    if html!=card.content
      card.content = html
    end
  end
end

