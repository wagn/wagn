card_reader :contextual_class
card_reader :disappear
card_reader :message

def deliver args={}
  success.flash alert_message(args[:context])
end

def alert_message context
  m_card = message.present? ? message_card : self
  view = m_card.format(:html).respond_to?(:notify) || :core
  format(:html).alert alert_class, true, disappear? do
    m_card.contextual_content(context, { format: :html }, view: view)
  end
end

def disappear?
  disappear.present? ? disappear_card.checked? : true
end

def alert_class
  contextual_class.present? ? contextual_class_card.item : :success
end
