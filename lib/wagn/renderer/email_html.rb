module Wagn
  class Renderer::EmailHtml < Renderer::Html
    def full_uri(relative_uri)
      System.base_url + relative_uri
    end
  end
end
