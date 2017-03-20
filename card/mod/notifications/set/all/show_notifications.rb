format :html do
  view :flash do
    flash_notice = Env.success.flash || params[:flash]
    return "" unless flash_notice && focal?
    Array(flash_notice).join "\n"
  end
end
