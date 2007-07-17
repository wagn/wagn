
# to hit all the cards on the server (for cache population) do something like this:
#> rake dump_cardnames | while read cardname; do url="http://localhost:3000/card/show/$cardname.json"; echo -n $url; curl -s -S $url > /dev/null; echo ""; done

task :dump_cardnames=>:environment do
  ActiveRecord::Base.connection.select_all("select name from cards order by name asc").each do |record|
    puts URI.escape(Cardname.escape(record['name']))
  end
end