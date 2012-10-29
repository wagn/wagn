class Wagn::Renderer::Html
  define_view :watch, :type=>'cardtype' do |args|
    wrap :watch do
      type_link = card.watching_type? ? "#{watching_type_cards} | " : ""
      link_args = if card.watching?
        ["unwatch", :off, "stop sending emails about changes to #{card.cardname}"]
      else
        ["watch", :on, "send emails about changes to #{card.cardname}"]
      end
      link_args[0] += " #{card.name} cards"
      link_args[2] += ' cards'
      type_link + watch_link( *link_args )
    end
  end
end
