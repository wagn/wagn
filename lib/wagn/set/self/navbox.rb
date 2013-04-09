module Wagn
  module Set::Self::Navbox
    include Sets

    format :html

    define_view :raw, :name=>:navbox do |args|
      input_args = { :class=>'navbox' }
      @@placeholder ||= begin
        p = Card["#{Card[:navbox].name}+*placeholder"] and p.raw_content
      end
      
      input_args[:placeholder] = @@placeholder if @@placeholder

      %{
        <form action="#{Card.path_setting '/:search'}" method="get" class="navbox-form nodblclick">
          #{ hidden_field_tag :view, 'content' }
          #{ text_field_tag :_keyword, '', input_args }
       </form>
      }
    end
    alias_view(:raw, {:name=>'navbox'}, :core)

    format :json

    define_view :complete, :name=>:search do |args|
      term = params['_keyword']
      if term =~ /^\+/ && main = params['main']
        term = main+term
      end

      exact = Card.fetch term, :new=>{}
      goto_cards = Card.search goto_wql(term)
      goto_cards.unshift exact.name if exact.known? && !goto_cards.map{|n| n.to_name.key}.include?(exact.key) 

      JSON({
        :search => true, # card.ok?( :read ),
        :add    => (exact.new_card? && exact.cardname.valid? && !exact.virtual? && exact.ok?( :create )),
        :new    => (exact.type_id==Card::CardtypeID &&
                    Card.new(:type_id=>exact.type_id).ok?(:create) &&
                    [exact.name, exact.cardname.url_key]
                   ),
        :goto   => goto_cards.map { |name| [name, highlight(name, term), name.to_name.url_key] }
      })
    end
  end

  class Renderer
    private

    #hacky.  here for override
    def goto_wql(term)
     { :complete=>term, :limit=>8, :sort=>'name', :return=>'name' }
    end

  end
end
