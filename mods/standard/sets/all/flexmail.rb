
event :flexmail, :after=>:extend, :on=>:update do 
  Card::Flexmail.mail_for self
end