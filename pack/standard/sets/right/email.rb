view :raw do |args|
  account = Account[ card.left.id ]
  account ? account.send('email') : ''
end
view :core, :raw
