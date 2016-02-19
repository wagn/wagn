# -*- encoding : utf-8 -*-

class Card
  class Diff
    class << self
      def complete a, b, opts={}
        Card::Diff::Builder.new(a, b, opts).complete
      end

      def summary a, b, opts={}
        Card::Diff::Builder.new(a, b, opts).summary
      end

      def render_added_chunk text
        "<ins class='diffins diff-green'>#{text}</ins>"
      end

      def render_deleted_chunk text, _count=true
        "<del class='diffdel diff-red'>#{text}</del>"
      end

      def render_chunk action, text
        case action
        when '+'      then render_added_chunk text
        when :added   then render_added_chunk text
        when '-'      then render_deleted_chunk text
        when :deleted then render_deleted_chunk text
        else text
        end
      end
    end
  end
end

