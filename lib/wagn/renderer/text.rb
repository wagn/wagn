module Wagn
  class Renderer::Text < Renderer
    def initialize card, opts
      super card,opts

      if @format=='css' && controller
        controller.response.headers["Cache-Control"] = "public"
      end
    end
  end
end
