format :html do
  view :notifications do
    return "" unless params[:notifications] && focal?
    params[:notifications].map do |nc|
      alert :success, true do
        nest nc, view: :core
      end
    end.join
  end
end
