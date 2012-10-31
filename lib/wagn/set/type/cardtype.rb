module Wagn::Set::Type::Cardtype
 
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

  include Wagn::Set::Type::Basic

  def on_type_change
    custom_validate_destroy
  end

  def validate_type_change
    custom_validate_destroy
  end

  def cards_of_type_exist?
    Session.as_bot { Card.count_by_wql :type_id=>id } > 0 
  end

  def custom_validate_destroy
    if cards_of_type_exist?
      errors.add :cardtype, "can't be altered because #{name} is a Cardtype and cards of this type still exist"
      false
    else
      true
    end
  end

end
