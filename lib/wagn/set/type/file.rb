# -*- encoding : utf-8 -*-
module Wagn
  module Set::Type::File
    #extend Sets

    module Model
      def item_names(args={})  # needed for flexmail attachments.  hacky.
        [self.cardname]
      end
    end
  end
end
