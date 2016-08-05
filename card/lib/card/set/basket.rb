class Card
  module Set
    # The purpose of a basket it that you can throw something in from
    # the same set in another mod.
    #
    # Example:
    #   # mod/01_core/set/self/head.rb:
    #   format :html do
    #     basket :js_tags
    #     view :core { output_basket :js_tags }
    #   end
    #
    #   # mod/02_shell/set/self/head.rb:
    #   format :html do
    #     add_to_basket :js_tags do |format|
    #       format.render_special_view
    #     end
    #   end
    module Basket
      # Define a basket in a set or format
      def basket name
        mattr_accessor "#{name}_content"
        send("#{name}_content=", [])
        define_method name do
          send("#{name}_content").map do |item|
            item.respond_to?(:call) ? item.call(self) : item
          end
        end
      end

      # Define a basket in an abstract set
      def abstract_basket name
        # the basket has to be defined on the including set
        # (instead on the set itself)
        define_singleton_method :included do |host|
          host.basket name
        end
      end

      def add_to_basket name, content=nil, &block
        content ||= block
        send("#{name}_content").send('<<', content)
      end
    end
  end
end
