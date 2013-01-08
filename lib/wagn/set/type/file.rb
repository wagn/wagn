module Wagn
  module Set
    module Type
      module File
    #include Sets

        module Model
          def item_names(args={})  # needed for flexmail attachments.  hacky.
            [self.cardname]
          end
        end
      end
    end
  end
end
