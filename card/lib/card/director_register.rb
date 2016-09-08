class Card
  # Keeps track of all cards that are part of the current act.
  # We need this global object for the card directors because cards
  # sometimes get expired and reloaded during an act.
  # The DirectorRegister ensures that the stage information don't get lost.
  class DirectorRegister
    cattr_accessor :act_card

    class << self
      def act_director
        return unless DirectorRegister.act_card
        DirectorRegister.act_card.director
      end

      def directors
        @directors ||= {}
      end

      def clear
        DirectorRegister.act_card = nil
        directors.each_pair do |card, _dir|
          card.director = nil
        end
        @directors = nil
      end

      def fetch card, opts={}
        return directors[card] if directors[card]
        directors.each_key do |dir_card|
          return dir_card.director if dir_card.name == card.name
        end
        directors[card] = card.new_director opts
      end

      def add director
        directors[director.card] = director
      end

      def card_changed old_card
        return unless (director = @directors.delete old_card)
        add director
      end

      def delete director
        return unless @directors
        @directors.delete director.card
        director.delete
      end

      def deep_delete director
        director.subdirectors.each do |subdir|
          deep_delete subdir
        end
        delete director
      end

      def running_act?
        (dir = DirectorRegister.act_director) && dir.running?
      end

      def to_s
        directors.values.map(&:to_s).join "\n"
      end
    end
  end
end
