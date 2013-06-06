# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::AllCss
    extend Sets
    
    format :css

    define_view :show do |args|
      render_raw
    end
    
  end
end
