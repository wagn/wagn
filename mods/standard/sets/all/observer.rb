[:create, :update, :read, :delete, :save].each do |action|
  event :observer, :after=>:extend, :on=>action do 
    Card::Observer.sent_event_mails self, :on => action
  end
end

