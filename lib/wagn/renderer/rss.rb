module Wagn
  class Renderer::Rss < Renderer::Html
    def full_uri(relative_uri)  Wagn::Conf[:base_url] + relative_uri  end
  end
end
