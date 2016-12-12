module CoreExtensions
  # methods for codenames and numerical ids
  module PersistentIdentifier
    def card
      Card[self]
    end

    def cardname
      Card.quick_fetch(self).cardname
    end

    def name
      Card.quick_fetch(self).name
    end
  end
end
