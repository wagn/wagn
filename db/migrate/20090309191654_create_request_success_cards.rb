class CreateRequestSuccessCards < ActiveRecord::Migration
  def self.up
    User.as :wagbot  do
      Card::Phrase.find_or_create(:name=>'*request+*thanks', :content=>'wagn/Request_Sent')
      Card.find_or_create(:name=>'Request Sent', :content=>"Thank you for requesting an account.  You will receive a reply shortly.")
    end
  end

  def self.down
  end
end
