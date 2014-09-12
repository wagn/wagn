def toggle_subscription_for watcher
  following = watcher.fetch :trait=>:following, :new=>{:type=>:pointer}
  if following.items.include? card
    following.drop_item card.name
  else
    following.add_item card.name
  end
  following.save
end


format :html do
  watch_perms = lambda { |r| Auth.signed_in? && !r.card.new_card? }
  view :watch, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>watch_perms do |args|
    wrap args do
      link_args = if card.watched?
        [card,"following", :off, "stop sending emails about changes to #{card.cardname}", { :hover_content=> 'unfollow' } ]
      elsif card.type_watched?
        [card.type_card, "following", :off, "stop sending emails about changes to #{card.type_name} cards", { :hover_content=> 'unfollow' } ]
      else
        [card,"follow", :on, "send emails about changes to #{card.cardname}" ]
      end
      watch_link *link_args
    end
  end

  def watch_link watched_card, text, toggle, title, extra={}
    following = Auth.current.fetch :trait=>:following, :new=>{:type=>:pointer}
    path = case toggle
      when :off
        wagn_path "update/#{following.url_key}?drop_item=#{watched_card.url_key}"
      when :on 
        wagn_path "update/#{following.url_key}?add_item=#{watched_card.url_key}"
      end
    link_to "#{text}",  path, 
      {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :title=>title, :remote=>true, :method=>'post'}.merge(extra)
  end
  
end


# event :notify_followers, :after=>:extend do
# end


def type_watched?; Auth.current.fetch(:trait=>:following).include_item? type_name end
def watched?;     Auth.current.fetch(:trait=>:following).include_item? name end

def card_watchers
  Card.search :plus=>[{:codename=> "following"},{:link_to=>card.name}]
end

def type_watchers
  Card.search :plus=>[{:codename=> "following"},{:link_to=>card.type_name}]
end

def set_watchers
end

