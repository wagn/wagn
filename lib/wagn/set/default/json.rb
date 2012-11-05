module Wagn
  module Set::Default::Json
    include Sets

    format :json

    define_view :name_complete do |args|
      JSON( card.item_cards( :complete=>params['term'], :limit=>8, :sort=>'name', :return=>'name', :context=>'' ) )
    end
  end
end
