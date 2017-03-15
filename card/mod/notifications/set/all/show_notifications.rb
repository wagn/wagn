format :html do
  view :flash do
    return "" unless params[:flash] && focal?
    Array(params[:flash]).join "\n"
  end
end
