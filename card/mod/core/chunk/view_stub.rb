class Card
  class Content
    module Chunk
      class ViewStub < Abstract
        Chunk.register_class(
          self,
          prefix_re: Regexp.escape("<card-view>"),
          full_re: /\<card-view\>([^\<]*)\<\/card-view\>/,
          idx_char: "<"
        )

        def interpret match, _content
          @options_json = match[1]
          @card_cast, @options = JSON.parse @options_json
          @card_cast.symbolize_keys!
          @options.symbolize_keys!
        end

        def process_chunk
          @card = Card.fetch_from_cast @card_cast
          @processed = yield @card, @options
        end
      end
    end
  end
end
