class Card
  def act opts={}
    if !DirectorRegister.act_card
      DirectorRegister.clear
      self.director = nil
      DirectorRegister.act_card = self
      main_act_block = true
      if opts[:success]
        Env[:success] = Success.new(cardname, Env.params[:success])
      end
    else
      main_act_block = false
    end
    yield
  ensure
    DirectorRegister.clear if main_act_block
  end

  def self.new_director card, opts={}
    if opts[:parent]
      StageSubdirector.new card, opts
    elsif DirectorRegister.act_card &&
          DirectorRegister.act_card != card &&
          DirectorRegister.act_card.director.running?
      DirectorRegister.act_card.director.subdirectors.add(card)
    else
      StageDirector.new card
    end
  end

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
        directors[card] ||= Card.new_director card, opts
      end

      def add director
        directors[director.card] = director
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

      def to_s
        directors.values.map(&:to_s).join "\n"
      end
    end
  end
end
