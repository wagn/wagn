namespace :convert do
  task :markdown => :environment do
    require_gem 'BlueCloth'
    User.as :wagbot
    Card.find(:all, :order=>'name').each do |card|
      puts "Converting #{card.name}"
      html = BlueCloth.new(card.content || "").to_html
      if html!=card.content
        card.content = html
      end
    end
  end

  task :textile => :environment do
    require_gem 'RedCloth'
    User.as :wagbot
    Card.find(:all, :order=>'name').each do |card|
      puts "Converting #{card.name}"
      r = RedCloth.new(card.content || "")
      html = r.to_html
      if html!=card.content
        card.content = html
      end
    end
  end

end
