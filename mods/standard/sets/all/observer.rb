[:create, :update, :delete].each do |action|
  event "observer_#{action}".to_sym, :after=>:approve, :on=>action do 
    Card::Observer.send_event_mails self, :on=>action
  end
end

# event :observer, :after=>:approve, :on=>:delete do
# #  byebug
#   Card::Observer.send_event_mails self, :on=>:delete
# end

