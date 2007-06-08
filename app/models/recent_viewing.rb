class RecentViewing < ActiveRecord::Base
  belongs_to :card
  belongs_to :viewer, :class_name=>'User', :foreign_key=>'viewer_id'
  
  class << self
    def log( c )
      # for card and viewer, can't just assign the association, because there are some cases
      # where it triggers a save of the associated object when we don't want
      # one-- ie. on Add Tag.  should have a test case for it.
      self.create({
        :card_id => c.card ? c.card.id : nil,
        :viewer_id => ::User.current_user ? ::User.current_user.id : nil, 
        :url =>  c.request.request_uri,
        :viewer_ip => c.request.remote_ip,
        :outcome => c.response.headers["Status"],
        :viewed_at => Time.now()
      })
    end
  end
end
