event :flexmail, :after=>:extend, :on=>:create do #|args|
  Card::Flexmail.mail_for self
end
