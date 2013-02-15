module Wagn
  class Renderer::Rss < Renderer::Html

    def internal_url relative_path
      wagn_url relative_path
    end

  end
end
