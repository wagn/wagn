module Wagn::Set::Type::File
  def item_names(args={})  # needed for flexmail attachments.  hacky.
    [self.cardname]
  end
end
