module Wagn::Set::Self
  module Settings
  end
  
  module XRead 
    def self.setting_group() :viewing      end
    def self.setting_seq()   1             end
  end

  module XContent 
    def self.setting_group() :viewing      end
    def self.setting_seq()   2             end
  end

  module XLayout
    def self.setting_group() :viewing      end
    def self.setting_seq()   3             end
  end

  module XTableOfContents
    def self.setting_group() :viewing      end 
    def self.setting_seq()   4             end
  end
  
  module XUpdate
    def self.setting_group() :editing      end
    def self.setting_seq()   1             end    
  end
  
  module XComment
    def self.setting_group() :editing      end
    def self.setting_seq()   2             end  
  end
  
  module XDelete
    def self.setting_group() :editing      end
    def self.setting_seq()   3             end
  end
  
  module XCaptcha
    def self.setting_group() :editing      end
    def self.setting_seq()   4             end
  end

  module XEditHelp
    def self.setting_group() :editing      end
    def self.setting_seq()   5             end
  end

  module XAccountable
    def self.setting_group() :editing      end
    def self.setting_seq()   6             end
  end
  
  module XCreate
    def self.setting_group() :creating     end
    def self.setting_seq()   1             end
  end
  
  module XDefault
    def self.setting_group() :creating     end
    def self.setting_seq()    2            end
  end
  
  module XAddHelp
    def self.setting_group() :creating     end
    def self.setting_seq()    3            end
  end
  
  module XAutoname
    def self.setting_group() :creating     end
    def self.setting_seq()    4            end
  end
  
  module XThanks
    def self.setting_group() :creating     end
    def self.setting_seq()    5            end
  end

  module XSend
    def self.setting_group() :creating     end
    def self.setting_seq()    6            end
  end  
end