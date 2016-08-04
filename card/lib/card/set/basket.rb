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
      def basket name
        mattr_accessor name
        send("#{name}=", [])
        define_method name do
          basket_content name
        end
      end

      def add_to_basket name, content=nil, &block
        content ||= block
        send(name).send('<<', content)
      end
    end
  end
end
