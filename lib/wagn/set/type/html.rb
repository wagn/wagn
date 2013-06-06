# -*- encoding : utf-8 -*-
module Wagn
  module Set::Type::Html
  #extend Sets

    module Model
      def clean_html?
        false
      end
    end
  end
end
