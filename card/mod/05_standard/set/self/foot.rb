
format :html do
  view :raw do |_args|
    "<!-- *foot is deprecated. please remove from layout -->"
  end

  view :core, :raw
end
