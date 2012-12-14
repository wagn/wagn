module Wagn
  class Renderer::Rss < Renderer::Html

    def full_uri relative_uri
      wagn_url relative_uri
    end

  end
end
