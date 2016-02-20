class Card
  class SubdirectorArray < Array
    def self.initialize_with_subcards parent
      dir_array = new(parent)
      parent.card.subcards.each_card do |subcard|
        dir_array.add subcard
      end
      dir_array
    end

    def initialize parent
      @parent = parent
      super()
    end

    def add card
      if card.is_a? Card::StageDirector
        card = card.card
      end
      each do |dir|
        return dir if dir.card == card
      end
      dir = Card::DirectorRegister.fetch card, parent: @parent
      dir.main = false
      dir.parent = @parent
      self << dir
      dir
    end

    alias_method :delete_director, :delete

    def delete card
      if card.is_a? Card::StageDirector
        delete_director card
      else
        delete_if { |dir| dir.card == card }
      end
    end

    def add_director dir
      add dir.card
    end
  end
end
