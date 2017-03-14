def deliver args={}
  success.params[:notifications] ||= []
  success.params[:notifications] << self
end

