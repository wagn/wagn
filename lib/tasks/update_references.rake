namespace :db do
  namespace :references do
    desc "update references (via rendering) for every cards"
    task :update_all => :environment do
      # set all references to expired
      puts "Marking all card references as expired"
      ActiveRecord::Base.connection.execute %{update cards set references_expired=1}
      expired_cards_remain = true
      batchsize, count_updated = 100, 0
      Session.as_bot 
      while expired_cards_remain 
        batch = Card.find_all_by_references_expired(1, :order=>"name ASC", :limit=>batchsize)
        if batch.empty?
          puts "All card references updated!"
          expired_cards_remain = false
        else
          print "Updating references for '#{batch.first.name}' to '#{batch.last.name}' ... "; $stdout.flush
          batch.each do |card|
            Wagn::Renderer.new(card, :not_current=>true).update_references
          end
          count_updated+=batchsize
          puts "done.  \t\t#{count_updated} total updated"
        end
      end
    end
  end
end
