# -*- encoding : utf-8 -*-
module Wagn
  module Set::Type::Html
  #extend Set

    module Model
      def clean_html?
        false
      end
    end
  end
end
