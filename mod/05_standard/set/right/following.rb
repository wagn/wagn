event :update_watch_list, :before=>:approve, :on=>:update do
  # watched_card = Env.params[:watch]
  # case Env.params[:toggle]
  # when "on"
  #   add_item watched_card
  # when "off"
  #   drop_item watched_card
  # end
end

def show view, args
  Env.ajax? ? super(:watch, args) : super
end

format :html do
  watch_perms = lambda { |r| Auth.signed_in? && !r.card.new_card? }
  view :watch, :tags=>[:unknown_ok, :no_wrap_comments], :denial=>:blank, :perms=>watch_perms do |args|
    if watched_card = Card.fetch( Env.params[:watch] )
      wrap args do
        link_args = if card.watched?
          [watched_card,"following", :off, "stop sending emails about changes to #{card.cardname}", { :hover_content=> 'unfollow' } ]
        elsif card.type_watched?
          [watched_card.type_card, "following", :off, "stop sending emails about changes to #{card.type_name} cards", { :hover_content=> 'unfollow' } ]
        else
          [watched_card,"follow", :on, "send emails about changes to #{card.cardname}" ]
        end
        watch_link *link_args
      end
    else 
      errors.add :watch_error, "Unknown card #{Env.params[:watch]}"
    end
  end

  def watch_link watched_card, text, toggle, title, extra={}
    path = wagn_path "update/#{Auth.current.url_key}?watch=#{watched_card.url_key}&toggle=#{toggle}"
    link_to "#{text}",  path, 
      {:class=>"watch-toggle watch-toggle-#{toggle} slotter", :title=>title, :remote=>true, :method=>'post'}.merge(extra)
  end  
end
