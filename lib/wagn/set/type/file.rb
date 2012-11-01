module Wagn::Set::Type::File
  module Model
    def item_names(args={})  # needed for flexmail attachments.  hacky.
      [self.cardname]
    end
  end
end
