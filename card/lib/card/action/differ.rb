class Card
  class Action
    # a collection of methods for comparing actions
    module Differ
      # compare action's name value with previous name value
      # @return [rendered diff]
      def name_diff opts={}
        return unless new_name?
        diff_object(:name, opts).complete
      end

      # @return [rendered diff]
      # compare action's cardtype value with previous cardtype value
      def cardtype_diff opts={}
        return unless new_type?
        diff_object(:cardtype, opts).complete
      end

      # @return [rendered diff]
      # compare action's content value with previous content value
      def content_diff diff_type=:expanded, opts=nil
        return unless new_content?
        dobj = content_diff_object(opts)
        diff_type == :summary ? dobj.summary : dobj.complete
      end

      # test whether content was visibly removed
      # @return [true/false]
      def red?
        content_diff_object.red?
      end

      # test whether content was visibly added
      # @return [true/false]
      def green?
        content_diff_object.green?
      end

      private

      def diff_object field, opts
        Card::Content::Diff.new previous_value(field), value(field), opts
      end

      def content_diff_object opts=nil
        @diff ||= begin
          diff_args = opts || card.include_set_modules.diff_args
          diff_object :content, diff_args
        end
      end
    end
  end
end
