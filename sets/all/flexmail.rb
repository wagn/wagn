event :flexmail, :after=>:extend, :on=>:create do #|args|
  Flexmail.mail_for self
end