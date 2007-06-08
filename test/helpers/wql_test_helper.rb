module WqlTestHelper
  class Card::Base
    def children_for_test
      children.sort_by {|x| x.name }
    end
    
    def cousins_for_test() 
      return [] unless self.simple?  # is this right??
      (tag.cards.find :all, :conditions=>["id<>?",id]).sort_by {|x| x.name}
    end
  
    def relatives_for_test()
      (self.children(:order=>'id') + (simple? ? cousins : [])).sort_by {|x| x.name }
    end

    def pieces_for_test()  
      self.simple? ? [self] : [self, self.trunk.pieces, self.tag.root_card ].flatten.compact.uniq 
    end
  end


end
