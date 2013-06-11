view :raw do |args|
  account = User[ card.left.id ]
  account ? account.send('email') : ''
end
view :core, :raw