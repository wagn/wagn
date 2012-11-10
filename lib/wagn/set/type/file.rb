module Wagn
  module Set::Type::File
    #include Sets

    module Model
      def item_names(args={})  # needed for flexmail attachments.  hacky.
        [self.cardname]
      end
    end
  end
end
