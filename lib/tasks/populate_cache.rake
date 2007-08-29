
# to hit all the cards on the server (for cache population) do something like this:
#> rake dump_cardnames | while read cardname; do url="http://localhost:3000/card/show/$cardname.json"; echo -n $url; curl -s -S $url > /dev/null; echo ""; done

task :populate_cache=>:environment do
  ActiveRecord::Base.connection.select_all("select name from cards order by updated_at desc").each do |record|
    cardname = URI.escape(Cardname.escape(record['name']))
    url = "#{System.base_url}card/show/#{cardname}.json"
    cmd = "curl -s -S '#{url}' > /dev/null"
    puts url + " " + `#{cmd}`
  end
end