class Card
  class Action
    # a collection of methods for comparing actions
    module Diff
      def name_diff opts={}
        return unless new_name?
        Card::Content::Diff.complete previous_value(:name), value(:name), opts
      end

      def cardtype_diff opts={}
        return unless new_type?
        Card::Content::Diff.complete previous_value(:cardtype),
                                     value(:cardtype),
                                     opts
      end

      def content_diff diff_type=:expanded, opts=nil
        return unless new_content?
        if diff_type == :summary
          content_diff_object(opts).summary
        else
          content_diff_object(opts).complete
        end
      end

      def red?
        content_diff_object.red?
      end

      def green?
        content_diff_object.green?
      end

      private

      def content_diff_object opts=nil
        @diff ||= begin
          diff_args = opts || card.include_set_modules.diff_args
          Card::Content::Diff.new previous_value(:content),
                                  value(:content),
                                  diff_args
        end
      end
    end
  end
end
