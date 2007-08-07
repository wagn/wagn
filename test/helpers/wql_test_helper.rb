module WqlTestHelper
  class Card::Base
    def right_junctions_for_test
      right_junctions.sort_by {|x| x.name }
    end
    
    def left_junctions_for_test() 
      left_junctions.sort_by {|x| x.name }
    end
  
    def junctions_for_test()
      junctions.sort_by {|x| x.name }
    end

    def pieces_for_test()  
      pieces
    end
  end


end
