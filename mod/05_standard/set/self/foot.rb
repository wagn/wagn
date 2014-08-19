
format :html do
  view :raw do |args|
    '<!-- *foot is deprecated. please remove from layout -->'
  end

  view :core, :raw
end
