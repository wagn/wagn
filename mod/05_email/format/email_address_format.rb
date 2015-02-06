# -*- encoding : utf-8 -*-

class Card::EmailAddressFormat < Card::TextFormat  
  def link_to  text, href, opts={}
    if text and href != text
      "#{text} <#{href}>"
    else
      href
    end
  end

  def chunk_list
    :references
  end
end
