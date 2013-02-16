module Wagn
  module Set::All::AllCss
    include Sets
    
    format :css

    define_view :show do |args|
      render_raw
    end
    
  end
end