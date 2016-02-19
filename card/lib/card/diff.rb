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
    end
  end
end
