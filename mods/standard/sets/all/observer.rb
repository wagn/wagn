
class << self
  def send_timer_mails interval   
    Card.search( :right => Card[interval].name ).map(&:item_cards).flatten.each do |card|
      card.deliver
    end
  end
end

def deliver
  format(:format=>:email)._render_mail.deliver
end

def send_event_mails args  
  #byebug if args[:on] == :delete      
  setting = "on #{args[:on]}"    
  email_templates_for( setting ) do |card|
    card.deliver
  end
end

def email_templates_for setting
  if event_card = Card.fetch("#{self.name}+*self+*#{setting}")   #FIXME
  #if event_card = card.rule_card(setting)
    event_card.extended_item_cards.each do |mailcard|
      yield(mailcard)
    end
  end
end

[:create, :update, :delete, :save].each do |action|
  event "observer_#{action}".to_sym, :after=>:approve, :on=>action do 
    #Card::Set::All::Observer.send_event_mails self, :on=>action
    self.send_event_mails :on=>action
  end
end

event :observer_action, :after=>:approve do 
  self.send_event_mails :on=>:action
end

