format :html do
  view :flash do
    flash_notice = Env.success.params[:flash]
    return "" unless flash_notice && focal?
    Array(flash_notice).join "\n"
  end
end
