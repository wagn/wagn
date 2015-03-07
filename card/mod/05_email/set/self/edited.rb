include Card::FollowOption

self.restrictive_follow_opts :position=>2

self.follow_test do |opts|
  opts[:editor_ids].find { |editor_id| editor_id == opts[:user_id] }
end

self.follow_test_option :editor_ids do |card|
  Card.search( :editor_of=>card.name, :return=>:id ).map &:to_i
end


def title 
  'Following content you edited'
end

def label
  "follow if I edited"
end
  
def description set_card
  "#{set_card.follow_label} I edited"
end



