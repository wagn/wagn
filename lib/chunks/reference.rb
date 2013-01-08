require_dependency 'chunks/chunk'

module Chunks
  class Reference < Abstract
    attr_accessor :cardname

    def cardname= name
      return @cardname=nil unless name
      @cardname = name.to_name
    end

    def refcardname
      #warn "rercardname #{inspect}, #{cardname.to_absolute(card.cardname)}"
      cardname && self.cardname = cardname.to_absolute(card.cardname).to_name
    end

    def reference_card
      @refcard ||= refcardname && Card.fetch(refcardname)
    end

    def reference_id
      rc=reference_card and rc.id
    end

    def reference_name
      rc=refcardname and rc.key or ''
    end

    def link_text
      refcardname.to_s
    end

    def render_link
      renderer.build_link refcardname, self.link_text
    end
  end
end

