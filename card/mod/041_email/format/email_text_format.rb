# -*- encoding : utf-8 -*-

class Card::EmailTextFormat < Card::TextFormat
  def internal_url relative_path
    card_url relative_path
  end

  def chunk_list
    :references
  end
end
