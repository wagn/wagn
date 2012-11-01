# -*- encoding : utf-8 -*-
class StubCardController < CardController
  def url_options
    default_url_options
  end

  def params()  {} end
  def session() {} end
end
